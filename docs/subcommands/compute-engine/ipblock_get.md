# IpblockGet

Retrieves information about an IP Block.

```text
knife ionoscloud ipblock get (options)
```

## Available options:

### Required options:

* ipblock\_id

```text
    ionoscloud_url: --url URL
        the Ionoscloud API URL

    extra_config_file: --extra-config EXTRA_CONFIG_FILE_PATH, -e EXTRA_CONFIG_FILE_PATH
        path to the additional config file

    ipblock_id: --ipblock-id IPBLOCK_ID, -I IPBLOCK_ID
        iD of the IPBlock. (required)

    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password

    ionoscloud_token: --token PASSWORD
        your Ionoscloud access token

```
## Example

```text
knife ionoscloud ipblock get --url URL --extra-config EXTRA_CONFIG_FILE_PATH --ipblock-id IPBLOCK_ID --username USERNAME --password PASSWORD --token PASSWORD
```
