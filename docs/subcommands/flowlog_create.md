# FlowlogCreate

This will add a Flow Log to the network interface, NAT Gateway or Network Load Balancer.

```text
knife ionoscloud flowlog create (options)
```

## Available options:

### Required options:

* datacenter\_id
* type
* ionoscloud\_username
* ionoscloud\_password

```text
    datacenter_id: --datacenter-id DATACENTER_ID, -D DATACENTER_ID
        iD of the data center (required)

    type: --type FLOWLOG_TYPE, -t FLOWLOG_TYPE
        the object to which the flow log will be attached (required)

    server_id: --server-id SERVER_ID, -S SERVER_ID
        iD of the server

    nic_id: --nic-id NIC_ID, -N NIC_ID
        iD of the NIC

    natgateway_id: --natgateway NAT_GATEWAY_ID, -G NAT_GATEWAY_ID
        iD of the NAT Gateway

    network_loadbalancer_id: --network-loadbalancer NETWORK_LOADBALANCER, -L NETWORK_LOADBALANCER
        iD of the Network Load Balancer

    name: --name NAME, -n NAME
        name of the Flow Log

    action: --action ACTION, -a ACTION
        specifies the traffic action pattern. Must be one of ["ALL", "ACCEPTED", "REJECTED"].

    direction: --direction DIRECTION
        specifies the traffic direction pattern. Must be one of ["INGRESS", "EGRESS", "BIDIRECTIONAL"].

    bucket: --bucket BUCKET, -b BUCKET
        s3 bucket name of an existing IONOS Cloud S3 bucket. Ex. bucketName/key

    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username (required)

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password (required)

    extra_config_file: --extra-config EXTRA_CONFIG_FILE_PATH, -e EXTRA_CONFIG_FILE_PATH
        path to the additional config file

```
## Example

```text
knife ionoscloud flowlog create --datacenter-id DATACENTER_ID --type FLOWLOG_TYPE --server-id SERVER_ID --nic-id NIC_ID --natgateway NAT_GATEWAY_ID --network-loadbalancer NETWORK_LOADBALANCER --name NAME --action ACTION --direction DIRECTION --bucket BUCKET --username USERNAME --password PASSWORD --extra-config EXTRA_CONFIG_FILE_PATH
```
