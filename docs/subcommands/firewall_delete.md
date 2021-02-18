# FirewallDelete

Deletes a firewall rule from an existing NIC.

    knife ionoscloud firewall delete FIREWALL_ID [FIREWALL_ID] (options)


## Available options:
---

### Required options:
* datacenter_id
* server_id
* nic_id

```
    datacenter_id: --datacenter-id DATACENTER_ID, -D DATACENTER_ID
        the ID of the data center (required)

    server_id: --server-id SERVER_ID, -S SERVER_ID
        the ID of the server (required)

    nic_id: --nic-id NIC_ID, -N NIC_ID
        iD of the NIC (required)

    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password

```

## Example

    knife ionoscloud firewall delete FIREWALL_ID 