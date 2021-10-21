# LanUpdate

Updates information about a Ionoscloud LAN.

```text
knife ionoscloud lan update (options)
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

    name: --name NAME, -n NAME
        name of the server

    public: --public PUBLIC, -p PUBLIC
        boolean indicating if the LAN faces the public Internet or not; defaults to false

    pcc: --pcc PCC_ID
        iD of the PCC to connect the LAN to

    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username (required)

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password (required)

    extra_config_file: --extra-config EXTRA_CONFIG_FILE_PATH, -e EXTRA_CONFIG_FILE_PATH
        path to the additional config file

```
## Example

```text
knife ionoscloud lan update --datacenter-id DATACENTER_ID --lan-id LAN_ID --name NAME --public PUBLIC --pcc PCC_ID --username USERNAME --password PASSWORD --extra-config EXTRA_CONFIG_FILE_PATH
```
