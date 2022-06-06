# NicCreate

Creates a NIC on the specified server. The Ionoscloud platform supports adding multiple NICs to a server. These NICs can be used to create different, segmented networks on the platform.

```text
knife ionoscloud nic create (options)
```

## Available options:

### Required options:

* datacenter\_id
* server\_id
* lan

```text
    ionoscloud_url: --url URL
        the Ionoscloud API URL

    extra_config_file: --extra-config EXTRA_CONFIG_FILE_PATH, -e EXTRA_CONFIG_FILE_PATH
        path to the additional config file

    datacenter_id: --datacenter-id DATACENTER_ID, -D DATACENTER_ID
        name of the data center (required)

    server_id: --server-id SERVER_ID, -S SERVER_ID
        name of the server (required)

    name: --name NAME, -n NAME
        name of the NIC

    ips: --ips IP[,IP,...], -i IP[,IP,...]
        iPs assigned to the NIC

    dhcp: --dhcp, -d
        set to false if you wish to disable DHCP

    lan: --lan ID, -l ID
        the LAN ID the NIC will reside on; if the LAN ID does not exist it will be created (required)

    firewall_type: --firewall-type FIREWALL_TYPE, -t FIREWALL_TYPE
        the type of firewall rules that will be allowed on the NIC. If it is not specified it will take the default value INGRESS

    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password

    ionoscloud_token: --token PASSWORD
        your Ionoscloud access token

```
## Example

```text
knife ionoscloud nic create --url URL --extra-config EXTRA_CONFIG_FILE_PATH --datacenter-id DATACENTER_ID --server-id SERVER_ID --name NAME --ips IP[,IP,...] --dhcp --lan ID --firewall-type FIREWALL_TYPE --username USERNAME --password PASSWORD --token PASSWORD
```
