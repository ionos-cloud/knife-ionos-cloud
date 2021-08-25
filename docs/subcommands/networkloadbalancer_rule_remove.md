# NetworkloadbalancerRuleRemove

Removes the specified rules from a Network Loadbalancer under a data center.

```text
knife ionoscloud networkloadbalancer rule remove RULE_ID [RULE_ID] (options)
```

## Available options:

### Required options:

* datacenter\_id
* network\_loadbalancer\_id
* ionoscloud\_username
* ionoscloud\_password

```text
    datacenter_id: --datacenter-id DATACENTER_ID, -D DATACENTER_ID
        the ID of the data center (required)

    network_loadbalancer_id: --network-loadbalancer NETWORK_LOADBALANCER_ID, -L NETWORK_LOADBALANCER_ID
        iD of the Network Loadbalancer (required)

    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username (required)

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password (required)

    extra_config_file: --extra-config EXTRA_CONFIG_FILE, -e EXTRA_CONFIG_FILE
        additional config file name

```
## Example

```text
knife ionoscloud networkloadbalancer rule remove RULE_ID 
```
