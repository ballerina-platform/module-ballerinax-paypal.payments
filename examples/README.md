## Running an example

The `ballerinax/paypal.payments` connector provides practical examples illustrating usage in various scenarios. Explore these [examples](https://github.com/ballerina-platform/module-ballerinax-paypal.payments/tree/main/examples), covering use cases like product purchases with partial refunds, and subscription billing with pro-rated cancellations.

1. [**Order Creation**](https://github.com/ballerina-platform/module-ballerinax-paypal.payments/tree/main/examples/order-creation) - Create an order, authorize and capture payment, and perform staged refunds.

2. [**Subscription Management**](https://github.com/ballerina-platform/module-ballerinax-paypal.payments/tree/main/examples/subscription-management) - Simulate recurring subscription charges and handle pro-rated refund scenarios.

## Prerequisites

1. Generate PayPal credentials to authenticate the connector as described in the [Setup guide](https://developer.paypal.com/docs/api/overview/).

2. For each example, create a `Config.toml` file with the related configuration. Here's an example of how your `Config.toml` file should look:

    ```toml
    clientId = "<YOUR_PAYPAL_CLIENT_ID>"
    clientSecret = "<YOUR_PAYPAL_CLIENT_SECRET>"
    authId= "<YOUR_ORDER_AUTH_ID>"
    ```

## Running an Example

Execute the following commands to build an example from the source:

* To build an example:

    ```bash
    bal build
    ```

* To run an example:

    ```bash
    bal run
    ```


## Building the examples with the local module

**Warning**: Due to the absence of support for reading local repositories for single Ballerina files, the Bala of the module is manually written to the central repository as a workaround. Consequently, the bash script may modify your local Ballerina repositories.

Execute the following commands to build all the examples against the changes you have made to the module locally:

* To build all the examples:

    ```bash
    ./build.sh build
    ```

* To run all the examples:

    ```bash
    ./build.sh run
    ```

