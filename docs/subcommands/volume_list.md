# VolumeList

List all available volumes under a data center. You can also list all volumes attached to a specific server.

    knife ionoscloud volume list (options)


## Available options:
---

### Required options:
* datacenter_id

```
    datacenter_id: --datacenter-id DATACENTER_ID, -D DATACENTER_ID
        the ID of the virtul data center containing the volume (required)

    server_id: --server-id SERVER_ID, -S SERVER_ID
        the ID of the server

    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password

```

## Example

    knife ionoscloud volume list --datacenter-id DATACENTER_ID --server-id SERVER_ID --username USERNAME --password PASSWORD
