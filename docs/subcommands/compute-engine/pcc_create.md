# PccCreate

Creates a Private Cross-Connect.

```text
knife ionoscloud pcc create (options)
```

## Available options:

### Required options:


```text
    ionoscloud_url: --url URL
        the Ionoscloud API URL

    extra_config_file: --extra-config EXTRA_CONFIG_FILE_PATH, -e EXTRA_CONFIG_FILE_PATH
        path to the additional config file

    name: --name NAME, -n NAME
        name of the data center

    description: --description DESCRIPTION, -D DESCRIPTION
        description of the data center

    peers: --peers DATACENTER_ID,LAN_ID [DATACENTER_ID,LAN_ID]
        an array of LANs joined to this private cross connect

    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password

    ionoscloud_token: --token PASSWORD
        your Ionoscloud access token

```
## Example

```text
knife ionoscloud pcc create --url URL --extra-config EXTRA_CONFIG_FILE_PATH --name NAME --description DESCRIPTION --peers DATACENTER_ID,LAN_ID [DATACENTER_ID,LAN_ID] --username USERNAME --password PASSWORD --token PASSWORD
```
