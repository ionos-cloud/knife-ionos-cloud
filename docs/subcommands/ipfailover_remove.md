# IpfailoverRemove



    knife ionoscloud ipfailover remove (options)


## Available options:

```
* ionoscloud_username: --username USERNAME, -u USERNAME   Your Ionoscloud username
* ionoscloud_password: --password PASSWORD, -p PASSWORD   Your Ionoscloud password
* datacenter_id: --datacenter-id DATACENTER_ID, -D DATACENTER_ID   Name of the data center
* lan_id: --lan-id LAN_ID, -l LAN_ID   Lan ID
* ip: --ip IP, -i IP   IP to be added to IP failover group
* nic_id: --nic-id NIC_ID, -n NIC_ID   NIC to be added to IP failover group
```

## Example

    knife ionoscloud ipfailover remove --username USERNAME --password PASSWORD --datacenter-id DATACENTER_ID --lan-id LAN_ID --ip IP --nic-id NIC_ID
