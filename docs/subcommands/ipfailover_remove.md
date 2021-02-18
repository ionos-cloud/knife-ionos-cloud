# IpfailoverRemove

Remove IP Failover from LAN

    knife ionoscloud ipfailover remove (options)


## Available options:
---

### Required options:
* datacenter_id
* lan_id
* ip
* nic_id

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
        your Ionoscloud username

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password

```

## Example

    knife ionoscloud ipfailover remove --datacenter-id DATACENTER_ID --lan-id LAN_ID --ip IP --nic-id NIC_ID --username USERNAME --password PASSWORD