# LoadbalancerGet

Retrieves the attributes of a given load balancer. This will also retrieve a list of NICs associated with the load balancer.

```text
knife ionoscloud loadbalancer get (options)
```

## Available options:

### Required options:

* datacenter\_id
* loadbalancer\_id

```text
    ionoscloud_url: --url URL
        the Ionoscloud API URL

    extra_config_file: --extra-config EXTRA_CONFIG_FILE_PATH, -e EXTRA_CONFIG_FILE_PATH
        path to the additional config file

    datacenter_id: --datacenter-id DATACENTER_ID, -D DATACENTER_ID
        iD of the data center (required)

    loadbalancer_id: --loadbalancer-id LOADBALANCER_ID, -L LOADBALANCER_ID
        iD of the load balancer (required)

    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password

    ionoscloud_token: --token PASSWORD
        your Ionoscloud access token

```
## Example

```text
knife ionoscloud loadbalancer get --url URL --extra-config EXTRA_CONFIG_FILE_PATH --datacenter-id DATACENTER_ID --loadbalancer-id LOADBALANCER_ID --username USERNAME --password PASSWORD --token PASSWORD
```
