# NatgatewayRuleList

Lists all available rules in a NAT Gateways under a data center.

```text
knife ionoscloud natgateway rule list (options)
```

## Available options:

### Required options:

* datacenter\_id
* ionoscloud\_username
* ionoscloud\_password

```text
    datacenter_id: --datacenter-id DATACENTER_ID, -D DATACENTER_ID
        the ID of the data center (required)

    natgateway_id: --natgateway-id NATGATEWAY_ID, -G NATGATEWAY_ID
        iD of the NAT Gateway

    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username (required)

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password (required)

    extra_config_file: --extra-config EXTRA_CONFIG_FILE_PATH, -e EXTRA_CONFIG_FILE_PATH
        path to the additional config file

```
## Example

```text
knife ionoscloud natgateway rule list --datacenter-id DATACENTER_ID --natgateway-id NATGATEWAY_ID --username USERNAME --password PASSWORD --extra-config EXTRA_CONFIG_FILE_PATH
```
