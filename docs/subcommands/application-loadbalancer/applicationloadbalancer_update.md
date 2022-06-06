# ApplicationloadbalancerUpdate

Updates information about a Ionoscloud Application LoadBalancer.

```text
knife ionoscloud applicationloadbalancer update (options)
```

## Available options:

### Required options:

* datacenter\_id
* application\_loadbalancer\_id
* ionoscloud\_username
* ionoscloud\_password

```text
    ionoscloud_url: --url URL
        the Ionoscloud API URL

    extra_config_file: --extra-config EXTRA_CONFIG_FILE_PATH, -e EXTRA_CONFIG_FILE_PATH
        path to the additional config file

    datacenter_id: --datacenter-id DATACENTER_ID, -D DATACENTER_ID
        iD of the data center (required)

    application_loadbalancer_id: --application-loadbalancer APPLICATION_LOADBALANCER_ID, -L APPLICATION_LOADBALANCER_ID
        iD of the Application Loadbalancer (required)

    name: --name NAME, -n NAME
        name of the Application Load Balancer

    listener_lan: --listener-lan LISTENER_LAN_ID, -l LISTENER_LAN_ID
        id of the listening LAN. (inbound)

    target_lan: --target-lan TARGET_LAN_ID, -t TARGET_LAN_ID
        id of the balanced private target LAN. (outbound)

    ips: --ips IP[,IP,...], -i IP[,IP,...]
        collection of IP addresses of the Application Load Balancer. (inbound and outbound) IP of the listenerLan must be a customer reserved IP for the public load balancer and private IP for the private load balancer.

    lb_private_ips: --private-ips IP[,IP,...]
        collection of private IP addresses with subnet mask of the Application Load Balancer. IPs must contain valid subnet mask. If user will not provide any IP then the system will generate one IP with /24 subnet.

    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username (required)

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password (required)

    ionoscloud_token: --token PASSWORD
        your Ionoscloud access token

```
## Example

```text
knife ionoscloud applicationloadbalancer update --url URL --extra-config EXTRA_CONFIG_FILE_PATH --datacenter-id DATACENTER_ID --application-loadbalancer APPLICATION_LOADBALANCER_ID --name NAME --listener-lan LISTENER_LAN_ID --target-lan TARGET_LAN_ID --ips IP[,IP,...] --private-ips IP[,IP,...] --username USERNAME --password PASSWORD --token PASSWORD
```
