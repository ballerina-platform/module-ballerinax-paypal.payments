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
    string orderId = check createOrder();
    string authId = check authorizeOrder(orderId);
    
    paypal:CaptureRequest capturePayload = {
        amount: {
            value: "100.00",
            currency_code: "USD"
        },
        note_to_payer: "Payment for premium headphones"
    };
    
    paypal:Capture2 captureResponse = check paypal->/authorizations/[authId]/capture.post(capturePayload);
    string captureId = captureResponse.id ?: "";
    io:println("Headphones purchased: ", captureId);
    
    paypal:RefundRequest firstRefund = {
        amount: {
            value: "50.00",
            currency_code: "USD"
        },
        note_to_payer: "Partial refund - Month 1"
    };
    
    paypal:Refund firstRefundResponse = check paypal->/captures/[captureId]/refund.post(firstRefund);
    string firstRefundId = firstRefundResponse.id ?: "";
    io:println("Month 1 refund: ", firstRefundId);
    
    paypal:RefundRequest secondRefund = {
        amount: {
            value: "50.00",
            currency_code: "USD"
        },
        note_to_payer: "Partial refund - Month 2"
    };
    
    paypal:Refund secondRefundResponse = check paypal->/captures/[captureId]/refund.post(secondRefund);
    string secondRefundId = secondRefundResponse.id ?: "";
    io:println("Month 2 refund: ", secondRefundId);
}

isolated function createOrder() returns string|error {
    http:Client orderClient = check createHttpClient();
    
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
                    value: "100.00"
                },
                description: "Premium Wireless Headphones"
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

isolated function authorizeOrder(string orderId) returns string|error {
    http:Client orderClient = check createHttpClient();
    
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
                name: "John Smith",
                billing_address: {
                    address_line_1: "123 Main Street",
                    admin_area_2: "San Jose",
                    admin_area_1: "CA",
                    postal_code: "95131",
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

isolated function createHttpClient() returns http:Client|error {
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
