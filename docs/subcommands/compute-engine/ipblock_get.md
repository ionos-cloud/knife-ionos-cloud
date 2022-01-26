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
    extra_config_file: --extra-config EXTRA_CONFIG_FILE_PATH, -e EXTRA_CONFIG_FILE_PATH
        path to the additional config file

    ipblock_id: --ipblock-id IPBLOCK_ID, -I IPBLOCK_ID
        iD of the IPBlock. (required)

    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username (required)

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password (required)

    ionoscloud_url: --url URL
        the Ionoscloud API URL

```
## Example

```text
knife ionoscloud ipblock get --extra-config EXTRA_CONFIG_FILE_PATH --ipblock-id IPBLOCK_ID --username USERNAME --password PASSWORD --url URL
```
