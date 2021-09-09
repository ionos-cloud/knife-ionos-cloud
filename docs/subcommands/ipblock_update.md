# IpblockUpdate

Updates information about an IP Block.

```text
knife ionoscloud ipblock update (options)
```

## Available options:

### Required options:

* ipblock\_id
* ionoscloud\_username
* ionoscloud\_password

```text
    ipblock_id: --ipblock-id IPBLOCK_ID, -I IPBLOCK_ID
        iD of the IPBlock. (required)

    name: --name NAME, -n NAME
        name of the IP block

    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username (required)

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password (required)

    extra_config_file: --extra-config EXTRA_CONFIG_FILE_PATH, -e EXTRA_CONFIG_FILE_PATH
        path to the additional config file

```
## Example

```text
knife ionoscloud ipblock update --ipblock-id IPBLOCK_ID --name NAME --username USERNAME --password PASSWORD --extra-config EXTRA_CONFIG_FILE_PATH
```
