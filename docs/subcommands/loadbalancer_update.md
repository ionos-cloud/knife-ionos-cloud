# LoadbalancerUpdate

Updates information about a Ionoscloud Load Balancer.

```text
knife ionoscloud loadbalancer update (options)
```

## Available options:

### Required options:

* datacenter\_id
* loadbalancer\_id
* ionoscloud\_username
* ionoscloud\_password

```text
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
        your Ionoscloud username (required)

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password (required)

    extra_config_file: --extra-config EXTRA_CONFIG_FILE_PATH, -e EXTRA_CONFIG_FILE_PATH
        path to the additional config file

```
## Example

```text
knife ionoscloud loadbalancer update --datacenter-id DATACENTER_ID --loadbalancer-id LOADBALANCER_ID --name NAME --ip IP --dhcp DHCP --username USERNAME --password PASSWORD --extra-config EXTRA_CONFIG_FILE_PATH
```
