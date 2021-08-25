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
    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username (required)

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password (required)

    extra_config_file: --extra-config EXTRA_CONFIG_FILE, -e EXTRA_CONFIG_FILE
        additional config file name

```
## Example

```text
knife ionoscloud ipblock delete IPBLOCK_ID [IPBLOCK_ID]--username USERNAME --password PASSWORD --extra-config EXTRA_CONFIG_FILE
```
