_Author_: @pamaljayasinghe
_Created_: 21 June 2025
_Updated_: 21 June 2025
_Edition_: Swan Lake

# Sanitations for the OpenAPI specification

This document outlines the manual sanitizations applied to the PayPal Payments v2 OpenAPI specification. The official specification is initially retrieved from [PayPal's official GitHub repository](https://github.com/paypal/paypal-rest-api-specifications/blob/main/openapi/payments_payment_v2.json). After being flattened and aligned by the Ballerina OpenAPI tool, these manual modifications are implemented to improve the developer experience and to circumvent certain language and tool limitations.

## 1. Update OAuth2 token URL to relative URL.

**Location**: components.securitySchemes.Oauth2.flows.clientCredentials.tokenUrl

**Original**:
```
tokenUrl": "/v1/oauth2/token"
```

**Sanitized**:
```
https://api.sandbox.paypal.com/v1/oauth2/token
```

```diff
- "/v1/oauth2/token""
+ "https://api.sandbox.paypal.com/v1/oauth2/token"
```

**Reason**: Simplified endpoint paths for better readability and consistency with the base URL configuration.

## 2. Fix invalid generated schema names with special characters

**Original**:
```json
"Schema'409": {
    "properties": {
        "details": {
            "type": "array",
            "items": {
                "$ref": "#/components/schemas/409Details"
            }
        }
    }
},
"Schema'403": {
    "properties": {
        "details": {
            "type": "array",
            "items": {
                "$ref": "#/components/schemas/403Details"
            }
        }
    }
},
"Schema'401": {
    "properties": {
        "details": {
            "type": "array",
            "items": {
                "$ref": "#/components/schemas/401Details"
            }
        }
    }
},
"Schema'404": {
    "properties": {
        "details": {
            "type": "array",
            "items": {
                "$ref": "#/components/schemas/404Details"
            }
        }
    }
},
"Schema'400": {
    "properties": {
        "details": {
            "type": "array",
            "items": {
                "$ref": "#/components/schemas/400Details"
            }
        }
    }
},
"Schema'422": {
    "properties": {
        "details": {
            "type": "array",
            "items": {
                "$ref": "#/components/schemas/422Details"
            }
        }
    }
}
```

**Sanitized**:
```json
"Conflict": {
    "properties": {
        "details": {
            "type": "array",
            "items": {
                "$ref": "#/components/schemas/409Details"
            }
        }
    }
},
"Forbidden": {
    "properties": {
        "details": {
            "type": "array",
            "items": {
                "$ref": "#/components/schemas/403Details"
            }
        }
    }
},
"Unauthorized": {
    "properties": {
        "details": {
            "type": "array",
            "items": {
                "$ref": "#/components/schemas/401Details"
            }
        }
    }
},
"NotFound": {
    "properties": {
        "details": {
            "type": "array",
            "items": {
                "$ref": "#/components/schemas/404Details"
            }
        }
    }
},
"BadRequest": {
    "properties": {
        "details": {
            "type": "array",
            "items": {
                "$ref": "#/components/schemas/400Details"
            }
        }
    }
},
"UnprocessableEntity": {
    "properties": {
        "details": {
            "type": "array",
            "items": {
                "$ref": "#/components/schemas/422Details"
            }
        }
    }
}
```

```diff
- "Schema'409": {
+ "Conflict": {
    "properties": {
        "details": {
            "type": "array",
            "items": {
                "$ref": "#/components/schemas/409Details"
            }
        }
    }
},
- "Schema'403": {
+ "Forbidden": {
    "properties": {
        "details": {
            "type": "array",
            "items": {
                "$ref": "#/components/schemas/403Details"
            }
        }
    }
},
- "Schema'401": {
+ "Unauthorized": {
    "properties": {
        "details": {
            "type": "array",
            "items": {
                "$ref": "#/components/schemas/401Details"
            }
        }
    }
},
- "Schema'404": {
+ "NotFound": {
    "properties": {
        "details": {
            "type": "array",
            "items": {
                "$ref": "#/components/schemas/404Details"
            }
        }
    }
},
- "Schema'400": {
+ "BadRequest": {
    "properties": {
        "details": {
            "type": "array",
            "items": {
                "$ref": "#/components/schemas/400Details"
            }
        }
    }
},
- "Schema'422": {
+ "UnprocessableEntity": {
    "properties": {
        "details": {
            "type": "array",
            "items": {
                "$ref": "#/components/schemas/422Details"
            }
        }
    }
}
```

**Reason**: JSON keys with apostrophes (e.g., `Schema'409`) are invalid and break schema parsing; using plain, descriptive identifiers (e.g., `Conflict`, `NotFound`) ensures valid JSON Schema and prevents generator errors.

## 3. Avoid property name sanitisation to avoid data-binding error which is caused by a language limitation

**Location**: Various schema properties throughout the specification

**Original**:
```json
"x-ballerina-name": "propertyName"
```

**Sanitized**:
```json
"x-ballerina-name-ignore": "debugId"
```

```diff
- "x-ballerina-name": "debugId"
+ "x-ballerina-name-ignore": "debugId"
```

**Reason**: Due to issue [#38535](https://github.com/ballerina-platform/ballerina-lang/issues/38535); the data binding fails for the fields which have json data name annotations. This change will avoid adding these annotations to the fields.

## 4. Duplicate the field in the schema to avoid redeclared field error

**Location**: `components.schemas.CaptureRequest`

**Original**:
```json
"CaptureRequest": {
    "title": "Capture Request",
    "type": "object",
    "description": "Captures either a portion or the full authorized amount of an authorized payment",
    "allOf": [
        {
            "$ref": "#/components/schemas/SupplementaryPurchaseData"
        },
        {
            "$ref": "#/components/schemas/CaptureRequestAllOf2"
        }
    ]
}
```

**Sanitized**:
```json
"CaptureRequest": {
    "title": "Capture Request",
    "type": "object",
    "description": "Captures either a portion or the full authorized amount of an authorized payment",
    "allOf": [
        {
            "$ref": "#/components/schemas/SupplementaryPurchaseData"
        },
        {
            "$ref": "#/components/schemas/CaptureRequestAllOf2"
        },
        {
            "type": "object",
            "properties": {
                "invoice_id": {
                    "maxLength": 127,
                    "minLength": 1,
                    "pattern": "^.{1,127}$",
                    "type": "string",
                    "description": "The API caller-provided external invoice number for this order. Appears in both the payer's transaction history and the emails that the payer receives",
                    "x-ballerina-name-ignore": "invoiceId"
                },
                "note_to_payer": {
                    "maxLength": 255,
                    "minLength": 1,
                    "pattern": "^.{1,255}$",
                    "type": "string",
                    "description": "An informational note about this settlement. Appears in both the payer's transaction history and the emails that the payer receives",
                    "x-ballerina-name-ignore": "noteToPayer"
                }
            }
        }
    ]
}
```

```diff
"CaptureRequest": {
    "title": "Capture Request",
    "type": "object",
    "description": "Captures either a portion or the full authorized amount of an authorized payment",
    "allOf": [
        {
            "$ref": "#/components/schemas/SupplementaryPurchaseData"
        },
        {
            "$ref": "#/components/schemas/CaptureRequestAllOf2"
-        }
+        },
+        {
+            "type": "object",
+            "properties": {
+                "invoice_id": {
+                    "maxLength": 127,
+                    "minLength": 1,
+                    "pattern": "^.{1,127}$",
+                    "type": "string",
+                    "description": "The API caller-provided external invoice number for this order. Appears in both the payer's transaction history and the emails that the payer receives",
+                    "x-ballerina-name-ignore": "invoiceId"
+                },
+                "note_to_payer": {
+                    "maxLength": 255,
+                    "minLength": 1,
+                    "pattern": "^.{1,255}$",
+                    "type": "string",
+                    "description": "An informational note about this settlement. Appears in both the payer's transaction history and the emails that the payer receives",
+                    "x-ballerina-name-ignore": "noteToPayer"
+                }
+            }
+        }
    ]
}
```

**Reason**: Prevent duplicate symbol conflicts by explicitly defining properties that may be inherited from multiple schema references. This ensures clear field definitions and avoids compilation errors.

## OpenAPI CLI command

The following command was used to generate the Ballerina client from the OpenAPI specification. The command should be executed from the repository root directory.

```bash
bal openapi -i docs/spec/openapi.json --mode client --license docs/license.txt -o ballerina
```
**Note**: The license year is hardcoded to 2025, change if necessary.