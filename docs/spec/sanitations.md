_Author_:  @pamaljayasinghe \
_Created_: 06.21.2025 \
_Updated_: 06.21.2025\
_Edition_: Swan Lake

# Sanitation for OpenAPI specification

This document records the sanitation done on top of the official OpenAPI specification from Paypal Payments. 
The OpenAPI specification is obtained from (TODO: Add source link).
These changes are done in order to improve the overall usability, and as workarounds for some known language limitations.

[//]: # (TODO: Add sanitation details)
1. In types.bal file changed these into these values.

/v2/payments/authorizations/{authorization_id}" - /authorizations/{authorization_id}" 
    /v2/payments/authorizations/{authorization_id}/capture - /authorizations/{authorization_id}/capture
    /v2/payments/authorizations/{authorization_id}/reauthorize" : -
    /v2/payments/authorizations/{authorization_id}/void" -/authorizations/{authorization_id}/void"
    /v2/payments/captures/{capture_id}"  -/captures/{capture_id}" 
    /v2/payments/captures/{capture_id}/refund" -/captures/{capture_id}/refund"
    /v2/payments/refunds/{refund_id}" - /refunds/{refund_id}"

2.
3. 

## OpenAPI cli command

The following command was used to generate the Ballerina client from the OpenAPI specification. The command should be executed from the repository root directory.

```bash
bal openapi -i docs/spec/openapi.json --mode client -o ballerina
```
Note: The license year is hardcoded to 2025, change if necessary.
