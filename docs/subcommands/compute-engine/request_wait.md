# RequestWait

Waits until a request status is either DONE or FAILED.

```text
knife ionoscloud request wait (options)
```

## Available options:

### Required options:

* request\_id
* ionoscloud\_username
* ionoscloud\_password

```text
    extra_config_file: --extra-config EXTRA_CONFIG_FILE_PATH, -e EXTRA_CONFIG_FILE_PATH
        path to the additional config file

    request_id: --request-id REQUEST_ID, -R REQUEST_ID
        the ID of the Backup unit. (required)

    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username (required)

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password (required)

    ionoscloud_url: --url URL
        the Ionoscloud API URL

```
## Example

```text
knife ionoscloud request wait --extra-config EXTRA_CONFIG_FILE_PATH --request-id REQUEST_ID --username USERNAME --password PASSWORD --url URL
```
