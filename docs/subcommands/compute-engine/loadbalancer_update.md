# LoadbalancerUpdate

Updates information about a Ionoscloud Load Balancer.

```text
knife ionoscloud loadbalancer update (options)
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

    name: --name NAME, -n NAME
        name of the load balancer

    ip: --ip IP
        iPv4 address of the load balancer. All attached NICs will inherit this IP.

    dhcp: --dhcp DHCP
        indicates if the load balancer will reserve an IP using DHCP.

    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password

    ionoscloud_token: --token PASSWORD
        your Ionoscloud access token

```
## Example

```text
knife ionoscloud loadbalancer update --url URL --extra-config EXTRA_CONFIG_FILE_PATH --datacenter-id DATACENTER_ID --loadbalancer-id LOADBALANCER_ID --name NAME --ip IP --dhcp DHCP --username USERNAME --password PASSWORD --token PASSWORD
```
