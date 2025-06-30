// Copyright (c) 2025, WSO2 LLC. (http://www.wso2.com).
//
// WSO2 LLC. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/io;
import ballerina/http;
import ballerina/uuid;
import ballerinax/paypal.payments as paypal;

configurable string clientId = ?;
configurable string clientSecret = ?;

final paypal:Client paypal = check new (
    {
        auth: {
            clientId,
            clientSecret,
            tokenUrl: "https://api-m.sandbox.paypal.com/v1/oauth2/token"
        }
    }, 
    "https://api-m.sandbox.paypal.com/v2/payments"
);

public function main() returns error? {
    string orderId = check createSubscriptionOrder();
    string authId = check authorizeSubscriptionPayment(orderId);
    
    paypal:CaptureRequest firstMonthCapture = {
        amount: {
            value: "9.99",
            currency_code: "USD"
        },
        note_to_payer: "Music Premium - Month 1"
    };
    
    paypal:Capture2 firstCaptureResponse = check paypal->/authorizations/[authId]/capture.post(firstMonthCapture);
    string firstCaptureId = firstCaptureResponse.id ?: "";
    io:println("Month 1 captured: ", firstCaptureId);
    
    foreach int month in 2...4 {
        string monthlyOrderId = check createMonthlyRecurringOrder(month);
        string monthlyAuthId = check authorizeSubscriptionPayment(monthlyOrderId);
        
        paypal:CaptureRequest monthlyCapture = {
            amount: {
                value: "9.99",
                currency_code: "USD"
            },
            note_to_payer: string `Music Premium - Month ${month}`
        };
        
        paypal:Capture2 monthlyCaptureResponse = check paypal->/authorizations/[monthlyAuthId]/capture.post(monthlyCapture);
        string monthlyCaptureId = monthlyCaptureResponse.id ?: "";
        io:println(string `Month ${month} captured: `, monthlyCaptureId);
    }
    
    string basicOrderId = check createBasicPlanOrder();
    string basicAuthId = check authorizeSubscriptionPayment(basicOrderId);
    
    paypal:CaptureRequest basicPlanCapture = {
        amount: {
            value: "6.99",
            currency_code: "USD"
        },
        note_to_payer: "Music Basic - Month 5"
    };
    
    paypal:Capture2 basicCaptureResponse = check paypal->/authorizations/[basicAuthId]/capture.post(basicPlanCapture);
    string basicCaptureId = basicCaptureResponse.id ?: "";
    io:println("Month 5 Basic captured: ", basicCaptureId);
    
    paypal:RefundRequest proRatedRefund = {
        amount: {
            value: "3.50",
            currency_code: "USD"
        },
        note_to_payer: "Prorated refund for cancellation"
    };
    
    paypal:Refund refundResponse = check paypal->/captures/[basicCaptureId]/refund.post(proRatedRefund);
    string refundId = refundResponse.id ?: "";
    io:println("Refund processed: ", refundId);
}

isolated function createSubscriptionOrder() returns string|error {
    return createOrderWithAmount("9.99", "Music Premium Monthly Subscription");
}

isolated function createMonthlyRecurringOrder(int month) returns string|error {
    return createOrderWithAmount("9.99", string `Music Premium - Month ${month}`);
}

isolated function createBasicPlanOrder() returns string|error {
    return createOrderWithAmount("6.99", "Music Basic Monthly Subscription");
}

isolated function createOrderWithAmount(string amount, string description) returns string|error {
    http:Client orderClient = check createOrderHttpClient();
    
    record {|
        string intent;
        record {|
            record {|
                string currency_code;
                string value;
            |} amount;
            string description;
        |}[] purchase_units;
    |} orderPayload = {
        intent: "AUTHORIZE",
        purchase_units: [
            {
                amount: {
                    currency_code: "USD",
                    value: amount
                },
                description: description
            }
        ]
    };
    
    http:Response orderResponse = check orderClient->post("/v2/checkout/orders", orderPayload, {
        "Content-Type": "application/json"
    });
    
    json orderData = check orderResponse.getJsonPayload();
    string orderId = check orderData.id.ensureType(string);
    return orderId;
}

isolated function authorizeSubscriptionPayment(string orderId) returns string|error {
    http:Client orderClient = check createOrderHttpClient();
    
    record {|
        record {|
            record {|
                string number;
                string expiry;
                string security_code;
                string name;
                record {|
                    string address_line_1;
                    string admin_area_2;
                    string admin_area_1;
                    string postal_code;
                    string country_code;
                |} billing_address;
            |} card;
        |} payment_source;
    |} authorizePayload = {
        payment_source: {
            card: {
                number: "4111111111111111",
                expiry: "2029-08",
                security_code: "965",
                name: "Sarah Johnson",
                billing_address: {
                    address_line_1: "456 Music Ave",
                    admin_area_2: "Nashville",
                    admin_area_1: "TN",
                    postal_code: "37201",
                    country_code: "US"
                }
            }
        }
    };
    
    string requestId = uuid:createType1AsString();
    http:Response authResponse = check orderClient->post("/v2/checkout/orders/" + orderId + "/authorize", 
        authorizePayload, {
        "Content-Type": "application/json",
        "PayPal-Request-Id": requestId
    });
    
    json authData = check authResponse.getJsonPayload();
    json[] purchaseUnitsArray = <json[]>check authData.purchase_units;
    json firstUnit = purchaseUnitsArray[0];
    json payments = check firstUnit.payments;
    json[] authArray = <json[]>check payments.authorizations;
    json firstAuth = authArray[0];
    string authId = check firstAuth.id.ensureType(string);
    return authId;
}

isolated function createOrderHttpClient() returns http:Client|error {
    http:OAuth2ClientCredentialsGrantConfig oauthConfig = {
        clientId: clientId,
        clientSecret: clientSecret,
        tokenUrl: "https://api-m.sandbox.paypal.com/v1/oauth2/token"
    };
    
    http:ClientConfiguration httpClientConfig = {
        auth: oauthConfig,
        timeout: 60
    };
    
    return new ("https://api-m.sandbox.paypal.com", httpClientConfig);
}