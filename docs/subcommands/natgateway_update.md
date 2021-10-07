# NatgatewayUpdate

Updates information about a Ionoscloud NAT Gateway.

```text
knife ionoscloud natgateway update (options)
```

## Available options:

### Required options:

* datacenter\_id
* natgateway\_id
* ionoscloud\_username
* ionoscloud\_password

```text
    datacenter_id: --datacenter-id DATACENTER_ID, -D DATACENTER_ID
        iD of the data center (required)

    natgateway_id: --natgateway-id NATGATEWAY_ID, -G NATGATEWAY_ID
        iD of the NAT Gateway (required)

    name: --name NAME, -n NAME
        name of the NAT gateway

    ips: --ips IP[,IP,...], -i IP[,IP,...]
        collection of public IP addresses of the NAT gateway. Should be customer reserved IP addresses in that location

    lans: --lans LAN[,LAN,...]
        collection of LANs connected to the NAT gateway. IPs must contain valid subnet mask. If user will not provide any IP then system will generate an IP with /24 subnet.

    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username (required)

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password (required)

    extra_config_file: --extra-config EXTRA_CONFIG_FILE_PATH, -e EXTRA_CONFIG_FILE_PATH
        path to the additional config file

```
## Example

```text
knife ionoscloud natgateway update --datacenter-id DATACENTER_ID --natgateway-id NATGATEWAY_ID --name NAME --ips IP[,IP,...] --lans LAN[,LAN,...] --username USERNAME --password PASSWORD --extra-config EXTRA_CONFIG_FILE_PATH
```
