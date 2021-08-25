# LoadbalancerNicAdd

Adds the association of a NIC with a load balancer.

```text
knife ionoscloud loadbalancer nic add NIC_ID [NIC_ID] (options)
```

## Available options:

### Required options:

* datacenter\_id
* loadbalancer\_id
* ionoscloud\_username
* ionoscloud\_password

```text
    datacenter_id: --datacenter-id DATACENTER_ID, -D DATACENTER_ID
        name of the data center (required)

    loadbalancer_id: --loadbalancer-id LOADBALANCER_ID, -L LOADBALANCER_ID
        name of the load balancer (required)

    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username (required)

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password (required)

    extra_config_file: --extra-config EXTRA_CONFIG_FILE, -e EXTRA_CONFIG_FILE
        additional config file name

```
## Example

```text
knife ionoscloud loadbalancer nic add NIC_ID 
```
