# NatgatewayRuleAdd

Adds a Rule to a Nat Gateway under a data center.

```text
knife ionoscloud natgateway rule add (options)
```

## Available options:

### Required options:

* datacenter\_id
* natgateway\_id
* name
* source\_subnet
* public\_ip
* ionoscloud\_username
* ionoscloud\_password

```text
    datacenter_id: --datacenter-id DATACENTER_ID, -D DATACENTER_ID
        name of the data center (required)

    natgateway_id: --natgateway-id NATGATEWAY_ID, -G NATGATEWAY_ID
        iD of the NAT Gateway (required)

    name: --name NAME, -n NAME
        name of the NAT gateway rule (required)

    type: --type TYPE, -t TYPE
        type of the NAT gateway rule

    protocol: --protocol PROTOCOL, -p PROTOCOL
        protocol of the NAT gateway rule. Defaults to ALL. If protocol is 'ICMP' then target_port_range start and end cannot be set.

    source_subnet: --source SOURCE_SUBNET
        source subnet of the NAT gateway rule. For SNAT rules it specifies which packets this translation rule applies to based on the packets source IP address. (required)

    public_ip: --ip PUBLIC_IP, -i PUBLIC_IP
        public IP address of the NAT gateway rule. Specifies the address used for masking outgoing packets source address field. Should be one of the customer reserved IP address already configured on the NAT gateway resource (required)

    target_subnet: --target TARGET_SUBNET
        target or destination subnet of the NAT gateway rule. For SNAT rules it specifies which packets this translation rule applies to based on the packets destination IP address. If none is provided, rule will match any address

    target_port_range_start: --port-start PORT_RANGE_START
        target port range start associated with the NAT gateway rule

    target_port_range_end: --port-end PORT_RANGE_START
        target port range end associated with the NAT gateway rule

    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username (required)

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password (required)

    extra_config_file: --extra-config EXTRA_CONFIG_FILE_PATH, -e EXTRA_CONFIG_FILE_PATH
        path to the additional config file

```
## Example

```text
knife ionoscloud natgateway rule add --datacenter-id DATACENTER_ID --natgateway-id NATGATEWAY_ID --name NAME --type TYPE --protocol PROTOCOL --source SOURCE_SUBNET --ip PUBLIC_IP --target TARGET_SUBNET --port-start PORT_RANGE_START --port-end PORT_RANGE_START --username USERNAME --password PASSWORD --extra-config EXTRA_CONFIG_FILE_PATH
```
