# VolumeAttach

This will attach a pre-existing storage volume to the server.

    knife ionoscloud volume attach VOLUME_ID [VOLUME_ID] (options)


## Available options:
---

### Required options:
* datacenter_id
* server_id

```
    datacenter_id: --datacenter-id DATACENTER_ID, -D DATACENTER_ID
        the ID of the data center (required)

    server_id: --server-id SERVER_ID, -S SERVER_ID
        the ID of the server (required)

    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password

```

## Example

    knife ionoscloud volume attach VOLUME_ID 
