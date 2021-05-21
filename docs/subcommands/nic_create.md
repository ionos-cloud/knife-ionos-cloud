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
* ionoscloud\_username
* ionoscloud\_password

```text
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

    nat: --nat
        set to enable NAT on the NIC

    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username (required)

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password (required)

```
## Example

```text
knife ionoscloud nic create --datacenter-id DATACENTER_ID --server-id SERVER_ID --name NAME --ips IP[,IP,...] --dhcp --lan ID --nat --username USERNAME --password PASSWORD
```
