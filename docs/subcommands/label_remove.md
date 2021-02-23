# LabelRemove

Remove a Label from a Resource.

    knife ionoscloud label remove LABEL_KEY [LABEL_KEY] (options)


## Available options:
---

### Required options:
* type
* ionoscloud_username
* ionoscloud_password

```
    type: --resource-type RESOURCE_TYPE, -T RESOURCE_TYPE
        type of the resource to be labeled. (required)

    datacenter_id: --datacenter-id DATACENTER_ID, -D DATACENTER_ID
        iD of the data center.

    server_id: --server-id SERVER_ID, -S SERVER_ID
        iD of the server.

    volume_id: --volume-id VOLUME_ID, -V VOLUME_ID
        iD of the volume.

    ipblock_id: --ipblock-id IPBLOCK_ID, -I IPBLOCK_ID
        iD of the ipblock.

    snapshot_id: --snapshot-id SNAPSHOT_ID, -s SNAPSHOT_ID
        iD of the snapshot.

    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username (required)

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password (required)

```

## Example

    knife ionoscloud label remove LABEL_KEY 
