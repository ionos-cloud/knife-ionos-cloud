# IpfailoverAdd

Successfully setting up an IP Failover group requires three steps:
* Add a reserved IP address to a NIC that will become the IP Failover master.
* Use PATCH or PUT to enable ipFailover by providing the relevant ip and nicUuid values.
* Add the same reserved IP address to any other NICs that are a member of the same LAN. Those NICs will become IP Failover members.


    knife ionoscloud ipfailover add (options)


## Available options:
---

### Required options:
* datacenter_id
* lan_id
* ip
* nic_id
* ionoscloud_username
* ionoscloud_password

```
    datacenter_id: --datacenter-id DATACENTER_ID, -D DATACENTER_ID
        name of the data center (required)

    lan_id: --lan-id LAN_ID, -l LAN_ID
        lan ID (required)

    ip: --ip IP, -i IP
        iP to be added to IP failover group (required)

    nic_id: --nic-id NIC_ID, -n NIC_ID
        nIC to be added to IP failover group (required)

    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username (required)

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password (required)

```

## Example

    knife ionoscloud ipfailover add --datacenter-id DATACENTER_ID --lan-id LAN_ID --ip IP --nic-id NIC_ID --username USERNAME --password PASSWORD
