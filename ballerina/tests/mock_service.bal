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

import ballerina/http;
import ballerina/time;
import ballerina/uuid;

listener http:Listener httpListener = new(9090);

service / on httpListener {
    
    resource function post v1/oauth2/token(@http:Payload string payload) returns json|http:InternalServerError {
        return {
            access_token: "mock_access_token_123456",
            token_type: "Bearer",
            expires_in: 3600,
            scope: "https://uri.paypal.com/services/payments/payment"
        };
    }
    
    resource function get v2/payments/authorizations/[string id]() returns json {
        return {
            id: id,
            status: "CREATED",
            amount: { 
                value: "1.00", 
                currency_code: "USD" 
            },
            create_time: time:utcToString(time:utcNow()),
            update_time: time:utcToString(time:utcNow()),
            links: [
                {
                    href: "https://api-m.sandbox.paypal.com/v2/payments/authorizations/" + id,
                    rel: "self",
                    method: "GET"
                }
            ]
        };
    }
    
    resource function post v2/payments/authorizations/[string id]/capture(@http:Payload json requestBody) returns json {
        string captureId = id + "_capture_123";
        return {
            id: captureId,
            status: "COMPLETED",
            amount: { 
                value: "1.00", 
                currency_code: "USD" 
            },
            create_time: time:utcToString(time:utcNow()),
            update_time: time:utcToString(time:utcNow()),
            links: [
                {
                    href: "https://api-m.sandbox.paypal.com/v2/payments/captures/" + captureId,
                    rel: "self",
                    method: "GET"
                }
            ]
        };
    }
    
    resource function post v2/payments/authorizations/[string id]/reauthorize(@http:Payload json requestBody) returns json {
        string reauthId = id + "_reauth_123";
        return {
            id: reauthId,
            status: "CREATED",
            amount: { 
                value: "1.00", 
                currency_code: "USD" 
            },
            create_time: time:utcToString(time:utcNow()),
            update_time: time:utcToString(time:utcNow()),
            links: [
                {
                    href: "https://api-m.sandbox.paypal.com/v2/payments/authorizations/" + reauthId,
                    rel: "self",
                    method: "GET"
                }
            ]
        };
    }
    
    resource function post v2/payments/authorizations/[string id]/void() returns json {
        return {
            id: id,
            status: "VOIDED",
            create_time: time:utcToString(time:utcNow()),
            update_time: time:utcToString(time:utcNow())
        };
    }
    
    resource function get v2/payments/captures/[string id]() returns json {
        return {
            id: id,
            status: "COMPLETED",
            amount: { 
                value: "1.00", 
                currency_code: "USD" 
            },
            create_time: time:utcToString(time:utcNow()),
            update_time: time:utcToString(time:utcNow()),
            links: [
                {
                    href: "https://api-m.sandbox.paypal.com/v2/payments/captures/" + id,
                    rel: "self",
                    method: "GET"
                }
            ]
        };
    }
    
    resource function post v2/payments/captures/[string id]/refund(@http:Payload json requestBody) returns json {
        string refundId = id + "_refund_123";
        return {
            id: refundId,
            status: "COMPLETED",
            amount: { 
                value: "0.50", 
                currency_code: "USD" 
            },
            create_time: time:utcToString(time:utcNow()),
            update_time: time:utcToString(time:utcNow()),
            links: [
                {
                    href: "https://api-m.sandbox.paypal.com/v2/payments/refunds/" + refundId,
                    rel: "self",
                    method: "GET"
                }
            ]
        };
    }
    
    resource function get v2/payments/refunds/[string id]() returns json {
        return {
            id: id,
            status: "COMPLETED",
            amount: { 
                value: "0.50", 
                currency_code: "USD" 
            },
            create_time: time:utcToString(time:utcNow()),
            update_time: time:utcToString(time:utcNow()),
            links: [
                {
                    href: "https://api-m.sandbox.paypal.com/v2/payments/refunds/" + id,
                    rel: "self",
                    method: "GET"
                }
            ]
        };
    }
    
    resource function post v2/checkout/orders/[string id]/authorize(@http:Payload json requestBody) returns json|http:Response {
        json|error paymentSource = requestBody.payment_source;
        
        if (paymentSource is json) {
            json|error card = paymentSource.card;
            
            if (card is json) {
                json|error cardNumber = card.number;
                string cardNumberStr = "";
                if (cardNumber is json) {
                    cardNumberStr = cardNumber.toString();
                    if (cardNumberStr != "4111111111111111") {
                        http:Response response = new;
                        response.statusCode = 422;
                        json errorJson = {
                            "name": "UNPROCESSABLE_ENTITY",
                            "details": [
                                {
                                    "field": "/payment_source/card/number",
                                    "location": "body",
                                    "issue": "VALIDATION_ERROR",
                                    "description": "Invalid card number"
                            }
                        ],
                            "message": "The requested action could not be performed, semantically incorrect, or failed business validation.",
                            "debug_id": "mock_debug_id",
                            "links": [
                                {
                                    "href": "https://developer.paypal.com/api/rest/reference/orders/v2/errors/#VALIDATION_ERROR",
                                    "rel": "information_link",
                                    "method": "GET"
                                }
                            ]
                        };
                        response.setJsonPayload(errorJson);
                        return response;
                    }
                }
            }
        }
        
        string uuidStr = uuid:createType1AsString();
        string authId = id + "_auth_" + uuidStr;
        
        return {
            "id": id,
            "status": "COMPLETED",
            "purchase_units": [
                {
                    "reference_id": "default",
                    "payments": {
                        "authorizations": [
                            {
                                "id": authId,
                                "status": "CREATED",
                                "amount": {
                                    "currency_code": "USD",
                                    "value": "100.00"
                                },
                                "create_time": time:utcToString(time:utcNow()),
                                "update_time": time:utcToString(time:utcNow()),
                                "links": [
                                    {
                                        "href": "https://api-m.sandbox.paypal.com/v2/payments/authorizations/" + authId,
                                        "rel": "self",
                                        "method": "GET"
                                    }
                                ]
                            }
                        ]
                    }
                }
            ]
        };
    }
}