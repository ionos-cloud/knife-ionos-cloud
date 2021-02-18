# FirewallList

Lists all available firewall rules assigned to a NIC.

    knife ionoscloud firewall list (options)


## Available options:
---

### Required options:
* datacenter_id
* server_id
* nic_id

```
    datacenter_id: --datacenter-id DATACENTER_ID, -D DATACENTER_ID
        iD of the data center (required)

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

    knife ionoscloud firewall list --datacenter-id DATACENTER_ID --server-id SERVER_ID --nic-id NIC_ID --username USERNAME --password PASSWORD