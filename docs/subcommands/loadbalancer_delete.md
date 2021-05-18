# LoadbalancerDelete

Deletes the specified load balancer.

```text
knife ionoscloud loadbalancer delete LOAD_BALANCER_ID [LOAD_BALANCER_ID] (options)
```

## Available options:

### Required options:

* datacenter\_id
* ionoscloud\_username
* ionoscloud\_password

```text
    datacenter_id: --datacenter-id DATACENTER_ID, -D DATACENTER_ID
        name of the data center (required)

    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username (required)

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password (required)
```
## Example

```text
knife ionoscloud loadbalancer delete LOAD_BALANCER_ID 
```
