# FlowlogList

Lists all available flow logs assigned to a NIC, NAT Gateway or Network Load Balancer.

```text
knife ionoscloud flowlog list (options)
```

## Available options:

### Required options:

* datacenter\_id
* type
* ionoscloud\_username
* ionoscloud\_password

```text
    extra_config_file: --extra-config EXTRA_CONFIG_FILE_PATH, -e EXTRA_CONFIG_FILE_PATH
        path to the additional config file

    datacenter_id: --datacenter-id DATACENTER_ID, -D DATACENTER_ID
        iD of the data center (required)

    type: --type FLOWLOG_TYPE, -t FLOWLOG_TYPE
        the object to which the flow log will be attached (required)

    server_id: --server-id SERVER_ID, -S SERVER_ID
        the ID of the server

    nic_id: --nic-id NIC_ID, -N NIC_ID
        iD of the NIC

    natgateway_id: --nat-gateway NAT_GATEWAY_ID, -G NAT_GATEWAY_ID
        iD of the NAT Gateway

    network_loadbalancer_id: --network-loadbalancer NETWORK_LOADBALANCER, -L NETWORK_LOADBALANCER
        iD of the Network Load Balancer

    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username (required)

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password (required)

    ionoscloud_url: --url URL
        the Ionoscloud API URL

```
## Example

```text
knife ionoscloud flowlog list --extra-config EXTRA_CONFIG_FILE_PATH --datacenter-id DATACENTER_ID --type FLOWLOG_TYPE --server-id SERVER_ID --nic-id NIC_ID --nat-gateway NAT_GATEWAY_ID --network-loadbalancer NETWORK_LOADBALANCER --username USERNAME --password PASSWORD --url URL
```
