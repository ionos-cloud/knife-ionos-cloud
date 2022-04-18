# NetworkloadbalancerRuleTargetList

Lists all targets of a Network Loadbalancer Forwarding Rule under a data center.

```text
knife ionoscloud networkloadbalancer rule target list (options)
```

## Available options:

### Required options:

* datacenter\_id
* network\_loadbalancer\_id
* forwarding\_rule\_id
* ionoscloud\_username
* ionoscloud\_password

```text
    extra_config_file: --extra-config EXTRA_CONFIG_FILE_PATH, -e EXTRA_CONFIG_FILE_PATH
        path to the additional config file

    datacenter_id: --datacenter-id DATACENTER_ID, -D DATACENTER_ID
        the ID of the data center (required)

    network_loadbalancer_id: --network-loadbalancer NETWORK_LOADBALANCER_ID, -L NETWORK_LOADBALANCER_ID
        iD of the Network Loadbalancer (required)

    forwarding_rule_id: --forwarding-rule FORWARDING_RULE_ID, -R FORWARDING_RULE_ID
        iD of the Network Loadbalancer Forwarding Rule (required)

    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username (required)

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password (required)

    ionoscloud_url: --url URL
        the Ionoscloud API URL

```
## Example

```text
knife ionoscloud networkloadbalancer rule target list --extra-config EXTRA_CONFIG_FILE_PATH --datacenter-id DATACENTER_ID --network-loadbalancer NETWORK_LOADBALANCER_ID --forwarding-rule FORWARDING_RULE_ID --username USERNAME --password PASSWORD --url URL
```
