# LoadbalancerNicRemove

Removes the association of a NIC with a load balancer.

```text
knife ionoscloud loadbalancer nic remove NIC_ID [NIC_ID] (options)
```

## Available options:

### Required options:

* datacenter_id
* loadbalancer_id
* ionoscloud_username
* ionoscloud_password

```text
    datacenter_id: --datacenter-id DATACENTER_ID, -D DATACENTER_ID
        name of the data center (required)

    loadbalancer_id: --loadbalancer-id LOADBALANCER_ID, -L LOADBALANCER_ID
        name of the load balancer (required)

    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username (required)

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password (required)

```
## Example

```text
knife ionoscloud loadbalancer nic remove NIC_ID 
```
