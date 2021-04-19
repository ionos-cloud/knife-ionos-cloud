# LoadbalancerGet

Retrieves the attributes of a given load balancer. This will also retrieve a list of NICs associated with the load balancer.

```text
knife ionoscloud loadbalancer get (options)
```

## Available options:

### Required options:

* datacenter_id
* loadbalancer_id
* ionoscloud_username
* ionoscloud_password

```text
    datacenter_id: --datacenter-id DATACENTER_ID, -D DATACENTER_ID
        iD of the data center (required)

    loadbalancer_id: --loadbalancer-id LOADBALANCER_ID, -L LOADBALANCER_ID
        iD of the load balancer (required)

    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username (required)

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password (required)

```
## Example

```text
knife ionoscloud loadbalancer get --datacenter-id DATACENTER_ID --loadbalancer-id LOADBALANCER_ID --username USERNAME --password PASSWORD
```
