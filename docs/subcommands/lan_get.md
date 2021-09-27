# LanGet

Retrieves information about a Ionoscloud LAN.

```text
knife ionoscloud lan get (options)
```

## Available options:

### Required options:

* datacenter\_id
* lan\_id
* ionoscloud\_username
* ionoscloud\_password

```text
    datacenter_id: --datacenter-id DATACENTER_ID, -D DATACENTER_ID
        iD of the data center (required)

    lan_id: --lan-id LAN_ID, -L LAN_ID
        iD of the LAN (required)

    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username (required)

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password (required)

    extra_config_file: --extra-config EXTRA_CONFIG_FILE_PATH, -e EXTRA_CONFIG_FILE_PATH
        path to the additional config file

```
## Example

```text
knife ionoscloud lan get --datacenter-id DATACENTER_ID --lan-id LAN_ID --username USERNAME --password PASSWORD --extra-config EXTRA_CONFIG_FILE_PATH
```
