# IpblockDelete

Releases a currently assigned IP block.

```text
knife ionoscloud ipblock delete IPBLOCK_ID [IPBLOCK_ID]
```

## Available options:

### Required options:


```text
    ionoscloud_url: --url URL
        the Ionoscloud API URL

    extra_config_file: --extra-config EXTRA_CONFIG_FILE_PATH, -e EXTRA_CONFIG_FILE_PATH
        path to the additional config file

    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password

    ionoscloud_token: --token PASSWORD
        your Ionoscloud access token

```
## Example

```text
knife ionoscloud ipblock delete IPBLOCK_ID [IPBLOCK_ID]--url URL --extra-config EXTRA_CONFIG_FILE_PATH --username USERNAME --password PASSWORD --token PASSWORD
```
