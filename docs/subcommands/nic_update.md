# NicUpdate

Updates information about a Ionoscloud NIC.

```text
knife ionoscloud nic update (options)
```

## Available options:

### Required options:

* datacenter\_id
* server\_id
* nic\_id
* ionoscloud\_username
* ionoscloud\_password

```text
    extra_config_file: --extra-config EXTRA_CONFIG_FILE_PATH, -e EXTRA_CONFIG_FILE_PATH
        path to the additional config file

    datacenter_id: --datacenter-id DATACENTER_ID, -D DATACENTER_ID
        iD of the data center (required)

    server_id: --server-id SERVER_ID, -S SERVER_ID
        the ID of the server to which the NIC is assigned (required)

    nic_id: --nic-id NIC_ID, -N NIC_ID
        iD of the load balancer (required)

    name: --name NAME, -n NAME
        name of the NIC

    ips: --ips IP[,IP,...], -i IP[,IP,...]
        iPs assigned to the NIC

    dhcp: --dhcp DHCP
        set to false if you wish to disable DHCP

    lan: --lan ID, -l ID
        the LAN ID the NIC will reside on; if the LAN ID does not exist it will be created

    nat: --nat NAT
        set to enable NAT on the NIC

    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username (required)

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password (required)

    ionoscloud_url: --url URL
        the Ionoscloud API URL

```
## Example

```text
knife ionoscloud nic update --extra-config EXTRA_CONFIG_FILE_PATH --datacenter-id DATACENTER_ID --server-id SERVER_ID --nic-id NIC_ID --name NAME --ips IP[,IP,...] --dhcp DHCP --lan ID --nat NAT --username USERNAME --password PASSWORD --url URL
```
