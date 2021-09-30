# IpblockGet

Retrieves information about an IP Block.

```text
knife ionoscloud ipblock get (options)
```

## Available options:

### Required options:

* ipblock\_id
* ionoscloud\_username
* ionoscloud\_password

```text
    ipblock_id: --ipblock-id IPBLOCK_ID, -I IPBLOCK_ID
        iD of the IPBlock. (required)

    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username (required)

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password (required)

    extra_config_file: --extra-config EXTRA_CONFIG_FILE_PATH, -e EXTRA_CONFIG_FILE_PATH
        path to the additional config file

```
## Example

```text
knife ionoscloud ipblock get --ipblock-id IPBLOCK_ID --username USERNAME --password PASSWORD --extra-config EXTRA_CONFIG_FILE_PATH
```