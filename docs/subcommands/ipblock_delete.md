# IpblockDelete

Releases a currently assigned IP block.

```text
knife ionoscloud ipblock delete IPBLOCK_ID [IPBLOCK_ID]
```

## Available options:

### Required options:

* ionoscloud\_username
* ionoscloud\_password

```text
    extra_config_file: --extra-config EXTRA_CONFIG_FILE_PATH, -e EXTRA_CONFIG_FILE_PATH
        path to the additional config file

    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username (required)

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password (required)

    ionoscloud_url: --url URL
        the Ionoscloud API URL

```
## Example

```text
knife ionoscloud ipblock delete IPBLOCK_ID [IPBLOCK_ID]--extra-config EXTRA_CONFIG_FILE_PATH --username USERNAME --password PASSWORD --url URL
```
