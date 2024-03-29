# LoadbalancerCreate

Creates a load balancer within the VDC. Load balancers can be used for public or private IP traffic.

```text
knife ionoscloud loadbalancer create (options)
```

## Available options:

### Required options:

* datacenter\_id
* name

```text
    ionoscloud_url: --url URL
        the Ionoscloud API URL

    extra_config_file: --extra-config EXTRA_CONFIG_FILE_PATH, -e EXTRA_CONFIG_FILE_PATH
        path to the additional config file

    datacenter_id: --datacenter-id DATACENTER_ID, -D DATACENTER_ID
        name of the data center (required)

    name: --name NAME, -n NAME
        name of the load balancer (required)

    ip: --ip IP
        iPv4 address of the load balancer. All attached NICs will inherit this IP.

    dhcp: --dhcp DHCP, -d DHCP
        indicates if the load balancer will reserve an IP using DHCP.

    nics: --nics NIC_ID [NIC_ID]
        an array of additional private NICs attached to worker nodes

    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password

    ionoscloud_token: --token PASSWORD
        your Ionoscloud access token

```
## Example

```text
knife ionoscloud loadbalancer create --url URL --extra-config EXTRA_CONFIG_FILE_PATH --datacenter-id DATACENTER_ID --name NAME --ip IP --dhcp DHCP --nics NIC_ID [NIC_ID] --username USERNAME --password PASSWORD --token PASSWORD
```
