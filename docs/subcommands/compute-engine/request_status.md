# RequestStatus

Retrieves the status of a specific request based on the supplied request id.

```text
knife ionoscloud request status (options)
```

## Available options:

### Required options:

* request\_id

```text
    ionoscloud_url: --url URL
        the Ionoscloud API URL

    extra_config_file: --extra-config EXTRA_CONFIG_FILE_PATH, -e EXTRA_CONFIG_FILE_PATH
        path to the additional config file

    request_id: --request-id REQUEST_ID, -R REQUEST_ID
        the ID of the Request. (required)

    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password

    ionoscloud_token: --token PASSWORD
        your Ionoscloud access token

```
## Example

```text
knife ionoscloud request status --url URL --extra-config EXTRA_CONFIG_FILE_PATH --request-id REQUEST_ID --username USERNAME --password PASSWORD --token PASSWORD
```
