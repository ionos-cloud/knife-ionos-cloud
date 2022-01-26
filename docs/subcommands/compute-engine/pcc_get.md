# PccGet

Retrieves information about a Ionoscloud Private Cross Connect.

```text
knife ionoscloud pcc get (options)
```

## Available options:

### Required options:

* pcc\_id
* ionoscloud\_username
* ionoscloud\_password

```text
    extra_config_file: --extra-config EXTRA_CONFIG_FILE_PATH, -e EXTRA_CONFIG_FILE_PATH
        path to the additional config file

    pcc_id: --pcc-id PRIVATE_CROSS_CONNECT_ID, -P PRIVATE_CROSS_CONNECT_ID
        iD of the Private Cross Connect (required)

    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username (required)

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password (required)

    ionoscloud_url: --url URL
        the Ionoscloud API URL

```
## Example

```text
knife ionoscloud pcc get --extra-config EXTRA_CONFIG_FILE_PATH --pcc-id PRIVATE_CROSS_CONNECT_ID --username USERNAME --password PASSWORD --url URL
```
