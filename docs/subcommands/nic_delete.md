# NicDelete

Deletes an existing NIC from a server.

    knife ionoscloud nic delete NIC_ID [NIC_ID] (options)


## Available options:
---

### Required options:
* datacenter_id
* server_id

```
    datacenter_id: --datacenter-id DATACENTER_ID, -D DATACENTER_ID
        the ID of the data center (required)

    server_id: --server-id SERVER_ID, -S SERVER_ID
        the ID of the server assigned the NIC (required)

    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password

```

## Example

    knife ionoscloud nic delete NIC_ID 
