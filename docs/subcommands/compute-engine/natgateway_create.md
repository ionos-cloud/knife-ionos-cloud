# NatgatewayCreate

Creates a new Nat Gateway under a data center.

```text
knife ionoscloud natgateway create (options)
```

## Available options:

### Required options:

* datacenter\_id

```text
    ionoscloud_url: --url URL
        the Ionoscloud API URL

    extra_config_file: --extra-config EXTRA_CONFIG_FILE_PATH, -e EXTRA_CONFIG_FILE_PATH
        path to the additional config file

    datacenter_id: --datacenter-id DATACENTER_ID, -D DATACENTER_ID
        name of the data center (required)

    name: --name NAME, -n NAME
        name of the NAT gateway

    ips: --ips IP[,IP,...], -i IP[,IP,...]
        collection of public IP addresses of the NAT gateway. Should be customer reserved IP addresses in that location

    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password

    ionoscloud_token: --token PASSWORD
        your Ionoscloud access token

```
## Example

```text
knife ionoscloud natgateway create --url URL --extra-config EXTRA_CONFIG_FILE_PATH --datacenter-id DATACENTER_ID --name NAME --ips IP[,IP,...] --username USERNAME --password PASSWORD --token PASSWORD
```
