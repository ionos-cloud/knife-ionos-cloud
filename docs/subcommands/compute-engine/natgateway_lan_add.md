# NatgatewayLanAdd

Adds a LAN to a Nat Gateway under a data center.

```text
knife ionoscloud natgateway lan add (options)
```

## Available options:

### Required options:

* datacenter\_id
* natgateway\_id
* lan\_id

```text
    ionoscloud_url: --url URL
        the Ionoscloud API URL

    extra_config_file: --extra-config EXTRA_CONFIG_FILE_PATH, -e EXTRA_CONFIG_FILE_PATH
        path to the additional config file

    datacenter_id: --datacenter-id DATACENTER_ID, -D DATACENTER_ID
        name of the data center (required)

    natgateway_id: --natgateway-id NATGATEWAY_ID, -G NATGATEWAY_ID
        iD of the NAT Gateway (required)

    lan_id: --lan LAN_ID, -L LAN_ID
        iD of the LAN (required)

    gateway_ips: --ips IP[,IP,...], -i IP[,IP,...]
        collection of gateway IP addresses of the NAT gateway. Will be auto-generated if not provided. Should ideally be an IP belonging to the same subnet as the LAN

    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password

    ionoscloud_token: --token PASSWORD
        your Ionoscloud access token

```
## Example

```text
knife ionoscloud natgateway lan add --url URL --extra-config EXTRA_CONFIG_FILE_PATH --datacenter-id DATACENTER_ID --natgateway-id NATGATEWAY_ID --lan LAN_ID --ips IP[,IP,...] --username USERNAME --password PASSWORD --token PASSWORD
```
