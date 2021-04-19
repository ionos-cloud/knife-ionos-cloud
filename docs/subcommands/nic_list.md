# NicList

List all available NICs connected to a server.

```text
knife ionoscloud nic list (options)
```

## Available options:

### Required options:

* datacenter_id
* server_id
* ionoscloud_username
* ionoscloud_password

```text
    datacenter_id: --datacenter-id DATACENTER_ID, -D DATACENTER_ID
        the ID of the datacenter containing the NIC (required)

    server_id: --server-id SERVER_ID, -S SERVER_ID
        the ID of the server assigned the NIC (required)

    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username (required)

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password (required)

```
## Example

```text
knife ionoscloud nic list --datacenter-id DATACENTER_ID --server-id SERVER_ID --username USERNAME --password PASSWORD
```
