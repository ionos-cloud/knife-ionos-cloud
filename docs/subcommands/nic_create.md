# NicCreate



    knife ionoscloud nic create (options)


## Available options:

```
    ionoscloud_username: --username USERNAME, -u USERNAME
        Your Ionoscloud username

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        Your Ionoscloud password

    datacenter_id: --datacenter-id DATACENTER_ID, -D DATACENTER_ID
        Name of the data center

    server_id: --server-id SERVER_ID, -S SERVER_ID
        Name of the server

    name: --name NAME, -n NAME
        Name of the NIC

    ips: --ips IP[,IP,...], -i IP[,IP,...]
        IPs assigned to the NIC

    dhcp: --dhcp, -d
        Set to false if you wish to disable DHCP

    lan: --lan ID, -l ID
        The LAN ID the NIC will reside on; if the LAN ID does not exist it will be created

    nat: --nat
        Set to enable NAT on the NIC

```

## Example

    knife ionoscloud nic create --username USERNAME --password PASSWORD --datacenter-id DATACENTER_ID --server-id SERVER_ID --name NAME --ips IP[,IP,...] --dhcp --lan ID --nat
