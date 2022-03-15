# PccCreate

Creates a Private Cross-Connect.

```text
knife ionoscloud pcc create (options)
```

## Available options:

### Required options:

* ionoscloud\_username
* ionoscloud\_password

```text
    extra_config_file: --extra-config EXTRA_CONFIG_FILE_PATH, -e EXTRA_CONFIG_FILE_PATH
        path to the additional config file

    name: --name NAME, -n NAME
        name of the data center

    description: --description DESCRIPTION, -D DESCRIPTION
        description of the data center

    peers: --peers DATACENTER_ID,LAN_ID [DATACENTER_ID,LAN_ID]
        an array of LANs joined to this private cross connect

    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username (required)

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password (required)

    ionoscloud_url: --url URL
        the Ionoscloud API URL

```
## Example

```text
knife ionoscloud pcc create --extra-config EXTRA_CONFIG_FILE_PATH --name NAME --description DESCRIPTION --peers DATACENTER_ID,LAN_ID [DATACENTER_ID,LAN_ID] --username USERNAME --password PASSWORD --url URL
```