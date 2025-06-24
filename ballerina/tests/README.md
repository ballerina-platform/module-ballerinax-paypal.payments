# Running Tests

## Prerequisites

- OAuth2 credentials (Client ID & Secret) from your PayPal Developer account.

## Test Environments

There are two test environments for the PayPal Payments connector tests:

| Test Group   | Environment                          |
| ------------ | ------------------------------------ |
| `mock_tests` | Mock server for PayPal API (default) |
| `live_tests` | PayPal Sandbox API                   |

## Running Tests in the Mock Server

Ensure `IS_LIVE_SERVER` is either unset or set to `false` so that tests run against the mock server.

This environment variable can be configured within the `Config.toml` file in the `tests/` directory or specified as an environmental variable.

### Using a `Config.toml` file

Create a `Config.toml` file in the `/tests` directory and the following content:

```toml
isLiveServer = false
```

### Using Environment Variables

#### Linux or macOS

```bash
export IS_LIVE_SERVER=false
```

#### Windows

```bash
setx IS_LIVE_SERVER false
```

## Running Tests Against PayPal Sandbox API

Set `IS_LIVE_SERVER` to `true` and provide your OAuth2 credentials to target the PayPal Sandbox API.

### Using a `Config.toml` file

Create a `Config.toml` file in the `/tests` directory and the following content:

```toml
isLiveServer = true

clientId = "<your-paypal-client-id>"
clientSecret = "<your-paypal-client-secret>"
```

Then, run the following command to run the tests:

```bash
./gradlew clean test
```

### Using Environment Variables

#### Linux or macOS

```bash
export IS_LIVE_SERVER=true
export PAYPAL_CLIENT_ID="<your-paypal-client-id>"
export PAYPAL_CLIENT_SECRET="<your-paypal-client-secret>"
```

#### Windows

```bash
setx IS_LIVE_SERVER true
setx PAYPAL_CLIENT_ID <your-paypal-client-id>
setx PAYPAL_CLIENT_SECRET <your-paypal-client-secret>
```

Then, run the following command to run the tests:

```bash
./gradlew clean test
```

## Running Specific Groups or Test Cases

To run only certain test groups or individual test cases, pass the -Pgroups property:

```bash
./gradlew clean test -Pgroups=<comma-separated-groups-or-test-cases>
```

For example, to run only the mock tests:

```bash
./gradlew clean test -Pgroups=mock_tests
```