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
    pcc_id: --pcc-id PRIVATE_CROSS_CONNECT_ID, -P PRIVATE_CROSS_CONNECT_ID
        iD of the Private Cross Connect (required)

    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username (required)

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password (required)

    extra_config_file: --extra-config EXTRA_CONFIG_FILE_PATH, -e EXTRA_CONFIG_FILE_PATH
        path to the additional config file

```
## Example

```text
knife ionoscloud pcc get --pcc-id PRIVATE_CROSS_CONNECT_ID --username USERNAME --password PASSWORD --extra-config EXTRA_CONFIG_FILE_PATH
```
