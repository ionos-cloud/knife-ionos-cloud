# FlowlogUpdate

Updates information about a Ionoscloud Flow Log.

```text
knife ionoscloud flowlog update (options)
```

## Available options:

### Required options:

* flowlog\_id
* datacenter\_id
* type

```text
    ionoscloud_url: --url URL
        the Ionoscloud API URL

    extra_config_file: --extra-config EXTRA_CONFIG_FILE_PATH, -e EXTRA_CONFIG_FILE_PATH
        path to the additional config file

    datacenter_id: --datacenter-id DATACENTER_ID, -D DATACENTER_ID
        the ID of the data center (required)

    type: --type FLOWLOG_TYPE, -t FLOWLOG_TYPE
        the object to which the Flow Log will be attached (required)

    server_id: --server-id SERVER_ID, -S SERVER_ID
        the ID of the server

    nic_id: --nic-id NIC_ID, -N NIC_ID
        iD of the NIC

    natgateway_id: --nat-gateway NAT_GATEWAY_ID, -G NAT_GATEWAY_ID
        iD of the NAT Gateway

    network_loadbalancer_id: --network-loadbalancer NETWORK_LOADBALANCER, -L NETWORK_LOADBALANCER
        iD of the Network Load Balancer

    flowlog_id: --flowlog-id FLOWLOG_ID, -F FLOWLOG_ID
        the ID of the Flow Log (required)

    name: --name NAME, -n NAME
        name of the Flow Log

    action: --action ACTION, -a ACTION
        specifies the traffic action pattern. Must be one of ["ALL", "ACCEPTED", "REJECTED"].

    direction: --direction DIRECTION
        specifies the traffic direction pattern. Must be one of ["INGRESS", "EGRESS", "BIDIRECTIONAL"].

    bucket: --bucket BUCKET, -b BUCKET
        s3 bucket name of an existing IONOS Cloud S3 bucket. Ex. bucketName/key

    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password

    ionoscloud_token: --token PASSWORD
        your Ionoscloud access token

```
## Example

```text
knife ionoscloud flowlog update --url URL --extra-config EXTRA_CONFIG_FILE_PATH --datacenter-id DATACENTER_ID --type FLOWLOG_TYPE --server-id SERVER_ID --nic-id NIC_ID --nat-gateway NAT_GATEWAY_ID --network-loadbalancer NETWORK_LOADBALANCER --flowlog-id FLOWLOG_ID --name NAME --action ACTION --direction DIRECTION --bucket BUCKET --username USERNAME --password PASSWORD --token PASSWORD
```
