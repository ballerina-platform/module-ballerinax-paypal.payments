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
configurable string[] authIds = ?;

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
    paypal:CaptureRequest firstMonthCapture = {
        amount: {
            value: "9.99",
            currency_code: "USD"
        },
        note_to_payer: "Music Premium - Month 1"
    };
    
    paypal:Capture2 firstCaptureResponse = check paypal->/authorizations/[authIds[0]]/capture.post(firstMonthCapture);
    string firstCaptureId = firstCaptureResponse.id ?: "";
    io:println("Month 1 captured: ", firstCaptureId);
    
    foreach int month in 2...4 {
        paypal:CaptureRequest monthlyCapture = {
            amount: {
                value: "9.99",
                currency_code: "USD"
            },
            note_to_payer: string `Music Premium - Month ${month}`
        };
        
        paypal:Capture2 monthlyCaptureResponse = check paypal->/authorizations/[authIds[month - 1]]/capture.post(monthlyCapture);
        string monthlyCaptureId = monthlyCaptureResponse.id ?: "";
        io:println(string `Month ${month} captured: `, monthlyCaptureId);
    }
    
    paypal:CaptureRequest basicPlanCapture = {
        amount: {
            value: "6.99",
            currency_code: "USD"
        },
        note_to_payer: "Music Basic - Month 5"
    };
    
    paypal:Capture2 basicCaptureResponse = check paypal->/authorizations/[authIds[4]]/capture.post(basicPlanCapture);
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
