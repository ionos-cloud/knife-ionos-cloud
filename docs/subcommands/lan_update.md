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
    extra_config_file: --extra-config EXTRA_CONFIG_FILE_PATH, -e EXTRA_CONFIG_FILE_PATH
        path to the additional config file

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

    ip_failover: --ip-failover IPFAILOVER [IPFAILOVER]
        iP failover configurations for lan

    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username (required)

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password (required)

    ionoscloud_url: --url URL
        the Ionoscloud API URL

```
## Example

```text
knife ionoscloud lan update --extra-config EXTRA_CONFIG_FILE_PATH --datacenter-id DATACENTER_ID --lan-id LAN_ID --name NAME --public PUBLIC --pcc PCC_ID --ip-failover IPFAILOVER [IPFAILOVER] --username USERNAME --password PASSWORD --url URL
```
