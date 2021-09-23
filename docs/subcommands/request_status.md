# RequestStatus

Retrieves the status of a specific request based on the supplied request id.

```text
knife ionoscloud request status (options)
```

## Available options:

### Required options:

* request\_id
* ionoscloud\_username
* ionoscloud\_password

```text
    request_id: --request-id REQUEST_ID, -R REQUEST_ID
        the ID of the Request. (required)

    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username (required)

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password (required)

    extra_config_file: --extra-config EXTRA_CONFIG_FILE_PATH, -e EXTRA_CONFIG_FILE_PATH
        path to the additional config file
```

## Example

```text
knife ionoscloud request status --request-id REQUEST_ID --username USERNAME --password PASSWORD --extra-config EXTRA_CONFIG_FILE_PATH
```

