# SnapshotCreate

Creates a snapshot of a volume within the virtual data center. You can use a snapshot to create a new storage volume or to restore a storage volume.

    knife ionoscloud snapshot create (options)


## Available options:
---

### Required options:
* datacenter_id
* volume_id
* ionoscloud_username
* ionoscloud_password

```
    datacenter_id: --datacenter DATACENTER_ID, -D DATACENTER_ID
        iD of the Datacenter (required)

    volume_id: --volume VOLUME_ID, -V VOLUME_ID
        iD of the Volume (required)

    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username (required)

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password (required)

```

## Example

    knife ionoscloud snapshot create --datacenter DATACENTER_ID --volume VOLUME_ID --username USERNAME --password PASSWORD
