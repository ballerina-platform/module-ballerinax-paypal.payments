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
import ballerinax/paypal.payments as paypal;

configurable string clientId = ?;
configurable string clientSecret = ?;
configurable string serviceUrl = ?;
configurable string authId = ?;

final paypal:Client paypal = check new (
    {
        auth: {
            clientId,
            clientSecret,
            tokenUrl: "https://api-m.sandbox.paypal.com/v1/oauth2/token"
        }
    }, 
    serviceUrl
);

public function main() returns error? {
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
