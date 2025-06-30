# Ballerina PayPal Payments connector

[![Build](https://github.com/ballerina-platform/module-ballerinax-paypal.payments/actions/workflows/ci.yml/badge.svg)](https://github.com/ballerina-platform/module-ballerinax-paypal.payments/actions/workflows/ci.yml)
[![GitHub Last Commit](https://img.shields.io/github/last-commit/ballerina-platform/module-ballerinax-paypal.payments.svg)](https://github.com/ballerina-platform/module-ballerinax-paypal.payments/commits/master)
[![GitHub Issues](https://img.shields.io/github/issues/ballerina-platform/ballerina-library/module/paypal.payments.svg?label=Open%20Issues)](https://github.com/ballerina-platform/ballerina-library/labels/module%paypal.payments)

## Overview

[PayPal](https://www.paypal.com/) is a global online payment platform enabling individuals and businesses to securely send and receive money, process transactions, and access merchant services across multiple currencies.

The `ballerinax/paypal.payments` package provides a Ballerina connector for interacting with the [PayPal Payments API v2](https://developer.paypal.com/docs/api/payments/v2/), allowing you to authorize payments, capture authorized payments, refund captured payments, void authorizations, and reauthorize expired authorizations in your Ballerina applications.

## Setup guide

To use the PayPal Payments connector, you must have access to a [PayPal Developer account](https://developer.paypal.com/).

### Step 1: Create a business account

1. Open the [PayPal Developer Dashboard](https://developer.paypal.com/dashboard).

2. Click on "Sandbox Accounts" under "Testing Tools".

   ![Sandbox accounts](https://raw.githubusercontent.com/ballerina-platform/module-ballerinax-paypal.payments/main/docs/setup/resources/sandbox-accounts.png)

3. Create a Business account

   > Note: Some PayPal options and features may vary by region or country; check availability before creating an account.

   ![Create business account](https://raw.githubusercontent.com/ballerina-platform/module-ballerinax-paypal.payments/main/docs/setup/resources/create-account.png)

### Step 2: Create a REST API app

1. Navigate to the "Apps and Credentials" tab and create a new merchant app.

   Provide a name for the application and select the Business account you created earlier.

   ![Create app](https://raw.githubusercontent.com/ballerina-platform/module-ballerinax-paypal.payments/main/docs/setup/resources/create-app.png)

### Step 3: Obtain Client ID and Client Secret

1. After creating your new app, you will see your **Client ID** and **Client Secret**. Make sure to copy and securely store these credentials.

   ![Credentials](https://raw.githubusercontent.com/ballerina-platform/module-ballerinax-paypal.payments/main/docs/setup/resources/get-credentials.png)

## Quickstart

To use the `paypal.payments` connector in your Ballerina application, update the `.bal` file as follows:

### Step 1: Import the module

Import the `paypal.payments` module.

```ballerina
import ballerinax/paypal.payments as paypal;
```

### Step 2: Instantiate a new connector

1. Create a `Config.toml` file and configure the obtained credentials in the above steps as follows:

```toml
clientId = "<test-client-id>"
clientSecret = "<test-client-secret>"

serviceUrl = "<paypal-service-url>"
tokenUrl = "<paypal-token-url>"
```

2. Create a `paypal:ConnectionConfig` with the obtained credentials and initialize the connector with it.

```ballerina
configurable string clientId = ?;
configurable string clientSecret = ?;

configurable string serviceUrl = ?;
configurable string tokenUrl = ?;
```

```ballerina
final paypal:Client paypal = check new ({
    auth: {
        clientId,
        clientSecret,
        tokenUrl
    }
}, serviceUrl);
```

### Step 3: Invoke the connector operation

Now, utilize the available connector operations.

#### Capture an authorized payment

```ballerina
public function main() returns error? {
    paypal:CaptureRequest captureRequest = {
        amount: {
            currency_code: "USD",
            value: "100.00"
        },
        final_capture: true
    };
    
    paypal:Capture2 response = check paypal->/authorizations/[authorizationId]/capture.post(captureRequest);
}
```

### Step 4: Run the Ballerina application

```bash
bal run
```

## Examples

The `PayPal Payments` connector provides practical examples illustrating usage in various scenarios. Explore these [examples](https://github.com/ballerina-platform/module-ballerinax-paypal.payments/tree/main/examples/), covering the following use cases:

1. [**Order creation**](https://github.com/ballerina-platform/module-ballerinax-paypal.payments/tree/main/examples/order-creation): Process a complete product purchase from order creation through payment authorization, capture, and partial refunds.

2. [**Subscription management**](https://github.com/ballerina-platform/module-ballerinax-paypal.payments/tree/main/examples/subscription-management): Simulate a recurring billing flow with subscription-style orders, monthly payments, plan switching, and pro-rated refunds.

## Build from the source

### Setting up the prerequisites

1. Download and install Java SE Development Kit (JDK) version 21. You can download it from either of the following sources:

    * [Oracle JDK](https://www.oracle.com/java/technologies/downloads/)
    * [OpenJDK](https://adoptium.net/)

   > **Note:** After installation, remember to set the `JAVA_HOME` environment variable to the directory where JDK was installed.

2. Download and install [Ballerina Swan Lake](https://ballerina.io/).

3. Download and install [Docker](https://www.docker.com/get-started).

   > **Note**: Ensure that the Docker daemon is running before executing any tests.

4. Export Github Personal access token with read package permissions as follows,

    ```bash
    export packageUser=<Username>
    export packagePAT=<Personal access token>
    ```

### Build options

Execute the commands below to build from the source.

1. To build the package:

   ```bash
   ./gradlew clean build
   ```

2. To run the tests:

   ```bash
   ./gradlew clean test
   ```

3. To build the without the tests:

   ```bash
   ./gradlew clean build -x test
   ```

4. To run tests against different environments:

   ```bash
   ./gradlew clean test -Pgroups=<Comma separated groups/test cases>
   ```

5. To debug the package with a remote debugger:

   ```bash
   ./gradlew clean build -Pdebug=<port>
   ```

6. To debug with the Ballerina language:

   ```bash
   ./gradlew clean build -PbalJavaDebug=<port>
   ```

7. Publish the generated artifacts to the local Ballerina Central repository:

    ```bash
    ./gradlew clean build -PpublishToLocalCentral=true
    ```

8. Publish the generated artifacts to the Ballerina Central repository:

   ```bash
   ./gradlew clean build -PpublishToCentral=true
   ```

## Contribute to Ballerina

As an open-source project, Ballerina welcomes contributions from the community.

For more information, go to the [contribution guidelines](https://github.com/ballerina-platform/ballerina-lang/blob/master/CONTRIBUTING.md).

## Code of conduct

All the contributors are encouraged to read the [Ballerina Code of Conduct](https://ballerina.io/code-of-conduct).

## Useful links

* For more information go to the [`paypal.payments` package](https://central.ballerina.io/ballerinax/paypal.payments/latest).
* For example demonstrations of the usage, go to [Ballerina By Examples](https://ballerina.io/learn/by-example/).
* Chat live with us via our [Discord server](https://discord.gg/ballerinalang).
* Post all technical questions on Stack Overflow with the [#ballerina](https://stackoverflow.com/questions/tagged/ballerina) tag.
