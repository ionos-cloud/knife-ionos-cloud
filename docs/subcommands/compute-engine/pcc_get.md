# PccGet

Retrieves information about a Ionoscloud Private Cross Connect.

```text
knife ionoscloud pcc get (options)
```

## Available options:

### Required options:

* pcc\_id

```text
    ionoscloud_url: --url URL
        the Ionoscloud API URL

    extra_config_file: --extra-config EXTRA_CONFIG_FILE_PATH, -e EXTRA_CONFIG_FILE_PATH
        path to the additional config file

    pcc_id: --pcc-id PRIVATE_CROSS_CONNECT_ID, -P PRIVATE_CROSS_CONNECT_ID
        iD of the Private Cross Connect (required)

    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password

    ionoscloud_token: --token PASSWORD
        your Ionoscloud access token

```
## Example

```text
knife ionoscloud pcc get --url URL --extra-config EXTRA_CONFIG_FILE_PATH --pcc-id PRIVATE_CROSS_CONNECT_ID --username USERNAME --password PASSWORD --token PASSWORD
```
