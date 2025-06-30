## Product purchase with partial refunds

This use case demonstrates how the PayPal Payments connector can be used to process a product order from creation through authorization, capture, and multiple partial refunds.

## Prerequisites

### 1. Setup a PayPal developer account

Refer to the [Setup guide](https://developer.paypal.com/docs/api/overview/) to obtain necessary credentials (Client ID and Client Secret).

### 2. Configuration

Create a `Config.toml` file in the example's root directory and add your PayPal credentials related configurations as follows:

```toml
clientId = "<your-paypal-client-id>"
clientSecret = "<your-paypal-client-secret>"
```

## Run the example

Execute the following command to run the example:

```bash
bal run
```
