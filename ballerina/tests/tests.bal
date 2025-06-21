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

import ballerina/test;
import ballerina/os;
import ballerina/http;
import ballerina/uuid;
import ballerina/time;

string clientIdEnv = os:getEnv("PAYPAL_CLIENT_ID");
configurable string SANDBOX_CLIENT_ID = clientIdEnv.length() > 0 ? clientIdEnv : "";

string clientSecretEnv = os:getEnv("PAYPAL_CLIENT_SECRET");
configurable string SANDBOX_CLIENT_SECRET = clientSecretEnv.length() > 0 ? clientSecretEnv : "";

configurable boolean useSandbox = ?;

string orderIdEnv = os:getEnv("PAYPAL_TEST_ORDER_ID");
configurable string TEST_ORDER_ID = orderIdEnv.length() > 0 ? orderIdEnv : "";

string authIdEnv = os:getEnv("PAYPAL_TEST_AUTH_ID");
configurable string TEST_AUTH_ID = authIdEnv.length() > 0 ? authIdEnv : "";

string captureIdEnv = os:getEnv("PAYPAL_TEST_CAPTURE_ID");
configurable string TEST_CAPTURE_ID = captureIdEnv.length() > 0 ? captureIdEnv : "";

string refundIdEnv = os:getEnv("PAYPAL_TEST_REFUND_ID");
configurable string TEST_REFUND_ID = refundIdEnv.length() > 0 ? refundIdEnv : "";

final string SANDBOX_URL = "https://api-m.sandbox.paypal.com";
final string MOCK_URL = "http://localhost:9090";
final string paypalServiceUrl = useSandbox ? SANDBOX_URL : MOCK_URL;

string testAuthId = "";
string testCaptureId = "";
string testRefundId = "";
string testOrderId = "";

isolated function createOrderHttpClient() returns http:Client|error {
    http:OAuth2ClientCredentialsGrantConfig oauthConfig = {
        clientId: useSandbox ? SANDBOX_CLIENT_ID : "test_client_id",
        clientSecret: useSandbox ? SANDBOX_CLIENT_SECRET : "test_client_secret",
        tokenUrl: paypalServiceUrl + "/v1/oauth2/token"
    };
    
    http:ClientConfiguration httpClientConfig = {
        auth: oauthConfig,
        timeout: 60
    };
    
    return new (paypalServiceUrl, httpClientConfig);
}

isolated function createTestOrder() returns string|error {
    if (!useSandbox) {
        return "mock_order_123";
    }
    
    if (TEST_ORDER_ID.length() > 0) {
        return TEST_ORDER_ID;
    }
    
    http:Client orderClient = check createOrderHttpClient();
    
    json orderPayload = {
        "intent": "AUTHORIZE",
        "purchase_units": [
            {
                "amount": {
                    "currency_code": "USD",
                    "value": "100.00"
                },
                "description": "Test order for Ballerina PayPal integration testing"
            }
        ]
    };
    
    http:Response orderResponse = check orderClient->post("/v2/checkout/orders", orderPayload, {
        "Content-Type": "application/json"
    });
    
    if (orderResponse.statusCode == 200 || orderResponse.statusCode == 201) {
        json orderData = check orderResponse.getJsonPayload();
        string orderId = check orderData.id;
        return orderId;
    }
    
    json responseBody = check orderResponse.getJsonPayload();
    return error("Failed to create order: " + orderResponse.statusCode.toString() + " - " + responseBody.toString());
}

isolated function authorizeTestOrder(string orderId) returns string|error {
    if (!useSandbox) {
        return "mock_auth_" + orderId;
    }
    
    if (TEST_AUTH_ID.length() > 0) {
        return TEST_AUTH_ID;
    }
    
    http:Client orderClient = check createOrderHttpClient();
    
    json authorizePayload = {
        "payment_source": {
            "card": {
                "number": "4111111111111111",
                "expiry": "2029-08",
                "security_code": "965",
                "name": "John Doe",
                "billing_address": {
                    "address_line_1": "123 Main St",
                    "admin_area_2": "San Jose",
                    "admin_area_1": "CA",
                    "postal_code": "95131",
                    "country_code": "US"
                }
            }
        }
    };
    
    string requestId = uuid:createType1AsString();
    
    http:Response authResponse = check orderClient->post("/v2/checkout/orders/" + orderId + "/authorize", authorizePayload, {
        "Content-Type": "application/json",
        "PayPal-Request-Id": requestId
    });
    
    if (authResponse.statusCode != 201) {
        json responseBody = check authResponse.getJsonPayload();
        return error("Failed to authorize order: " + authResponse.statusCode.toString() + " - " + responseBody.toString());
    }
    
    json authData = check authResponse.getJsonPayload();
    json purchaseUnits = check authData.purchase_units;
    json[] purchaseUnitsArray = <json[]>purchaseUnits;
    json firstUnit = purchaseUnitsArray[0];
    json payments = check firstUnit.payments;
    json authorizations = check payments.authorizations;
    json[] authArray = <json[]>authorizations;
    json firstAuth = authArray[0];
    string authId = check firstAuth.id;
    
    return authId;
}

isolated function createPayPalClient() returns Client|error {
    http:OAuth2ClientCredentialsGrantConfig oauthConfig = {
        clientId: useSandbox ? SANDBOX_CLIENT_ID : "test_client_id",
        clientSecret: useSandbox ? SANDBOX_CLIENT_SECRET : "test_client_secret",
        tokenUrl: paypalServiceUrl + "/v1/oauth2/token"
    };
    
    ConnectionConfig config = {
        auth: oauthConfig,
        timeout: 60
    };
    
    return new Client(config, paypalServiceUrl);
}

@test:BeforeSuite
function beforeAllTests() returns error? {
    if (useSandbox) {
        if (SANDBOX_CLIENT_ID.length() == 0 || SANDBOX_CLIENT_SECRET.length() == 0) {
            return error("Missing sandbox credentials");
        }
        
        if (TEST_AUTH_ID.length() > 0) {
            testAuthId = TEST_AUTH_ID;
        } else {
            string orderId = check createTestOrder();
            testOrderId = orderId;
            testAuthId = check authorizeTestOrder(orderId);
        }
        
        testCaptureId = TEST_CAPTURE_ID.length() > 0 ? TEST_CAPTURE_ID : "";
        testRefundId = TEST_REFUND_ID.length() > 0 ? TEST_REFUND_ID : "";
    } else {
        testOrderId = "mock_order_123";
        testAuthId = "testAuthId123";
        testCaptureId = "testCaptureId123";
        testRefundId = "testRefundId123";
    }
}

@test:Config { 
    groups: ["payments", "authorization"]
}
function testGetAuthorizationDetails() returns error? {
    Client paypal = check createPayPalClient();
    
    authorization\-2 response = check paypal->/v2/payments/authorizations/[testAuthId]();
    
    test:assertTrue(response.id is string && response.id != "", "Authorization ID should be a non-empty string");
    test:assertTrue(response.status is string && response.status != "", "Authorization status should be a non-empty string");
}

@test:Config { 
    groups: ["payments", "capture"],
    dependsOn: [testGetAuthorizationDetails]
}
function testCaptureAuthorization() returns error? {
    Client paypal = check createPayPalClient();
    
    capture_request payload = { 
        amount: { 
            value: "50.00", 
            currency_code: "USD" 
        },
        note_to_payer: "Test capture from Ballerina automated testing"
    };
    
    capture\-2 response = check paypal->/v2/payments/authorizations/[testAuthId]/capture.post(payload);
    
    test:assertTrue(response.id is string && response.id != "", "Capture ID should be a non-empty string");
    test:assertTrue(response.status is string && response.status != "", "Capture status should be a non-empty string");
    
    if (response.id is string) {
        testCaptureId = <string>response.id;
    }
}

@test:Config { 
    groups: ["payments", "reauthorization"],
    dependsOn: [testGetAuthorizationDetails]
}
function testReauthorizeAuthorization() returns error? {
    Client paypal = check createPayPalClient();
    
    reauthorize_request payload = { 
        amount: { 
            value: "75.00", 
            currency_code: "USD" 
        }
    };
    
    if (useSandbox) {
        authorization\-2|error response = paypal->/v2/payments/authorizations/[testAuthId]/reauthorize.post(payload);
        
        if (response is error) {
            if (response is http:ApplicationResponseError) {
                if (response.detail().statusCode == 422) {
                    json|error responseBody = <json>response.detail().body;
                    if (responseBody is json) {
                        json|error details = responseBody.details;
                        if (details is json[]) {
                            json firstDetail = details[0];
                            json|error issue = firstDetail.issue;
                            if (issue is string && (issue == "REAUTHORIZATION_TOO_SOON" || issue == "AUTHORIZATION_ALREADY_CAPTURED")) {
                                test:assertTrue(true, "Reauthorization correctly rejected: " + issue.toString());
                                return;
                            }
                        }
                    }
                }
            }
            return response;
        }
        
        test:assertTrue(response.id is string && response.id != "", "Reauthorization ID should be a non-empty string");
        test:assertTrue(response.status is string && response.status != "", "Reauthorization status should be a non-empty string");
    } else {
        authorization\-2 response = check paypal->/v2/payments/authorizations/[testAuthId]/reauthorize.post(payload);
        test:assertTrue(response.id is string && response.id != "", "Reauthorization ID should be a non-empty string");
        test:assertTrue(response.status is string && response.status != "", "Reauthorization status should be a non-empty string");
    }
}

@test:Config { 
    groups: ["payments", "void"],
    dependsOn: [testGetAuthorizationDetails]
}
function testVoidAuthorization() returns error? {
    string voidAuthId = testAuthId;
    
    if (useSandbox && TEST_AUTH_ID.length() == 0) {
        string newOrderId = check createTestOrder();
        voidAuthId = check authorizeTestOrder(newOrderId);
        time:Utc currentTime = time:utcNow();
        time:Utc delayUntil = time:utcAddSeconds(currentTime, 5);
        while (time:utcNow() < delayUntil) {
        }
    }
    
    Client paypal = check createPayPalClient();
    
    authorization\-2? response = check paypal->/v2/payments/authorizations/[voidAuthId]/void.post();
    
    if response is authorization\-2 {
        test:assertTrue(response.id is string, "Void response should contain an ID");
    }
}

@test:Config { 
    groups: ["payments", "capture-details"],
    dependsOn: [testCaptureAuthorization]
}
function testGetCaptureDetails() returns error? {
    Client paypal = check createPayPalClient();
    capture\-2 response = check paypal->/v2/payments/captures/[testCaptureId]();
    
    test:assertTrue(response.id is string && response.id != "", "Capture ID should be a non-empty string");
    test:assertTrue(response.status is string && response.status != "", "Capture status should be a non-empty string");
    test:assertEquals(response.id, testCaptureId, "Response ID should match the request ID");
}

@test:Config { 
    groups: ["payments", "refund"],
    dependsOn: [testGetCaptureDetails]
}
function testRefundCapture() returns error? {
    Client paypal = check createPayPalClient();
    
    refund_request payload = { 
        amount: { 
            value: "25.00", 
            currency_code: "USD" 
        },
        note_to_payer: "Test partial refund from Ballerina automated testing"
    };
    
    refund response = check paypal->/v2/payments/captures/[testCaptureId]/refund.post(payload);
    
    test:assertTrue(response.id is string && response.id != "", "Refund ID should be a non-empty string");
    test:assertTrue(response.status is string && response.status != "", "Refund status should be a non-empty string");
    
    if (response.id is string) {
        testRefundId = <string>response.id;
    }
}

@test:Config { 
    groups: ["payments", "refund-details"],
    dependsOn: [testRefundCapture]
}
function testGetRefundDetails() returns error? {
    Client paypal = check createPayPalClient();
    refund response = check paypal->/v2/payments/refunds/[testRefundId]();
    
    test:assertTrue(response.id is string && response.id != "", "Refund ID should be a non-empty string");
    test:assertTrue(response.status is string && response.status != "", "Refund status should be a non-empty string");
    test:assertEquals(response.id, testRefundId, "Response ID should match the request ID");
}

@test:AfterSuite
function afterAllTests() returns error? {
}