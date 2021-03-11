# SnapshotCreate

Creates a snapshot of a volume within the virtual data center. You can use a snapshot to create a new storage volume or to restore a storage volume.

    knife ionoscloud snapshot create (options)


## Available options:
---

### Required options:
* datacenter_id
* volume_id
* name
* ionoscloud_username
* ionoscloud_password

```
    datacenter_id: --datacenter DATACENTER_ID, -D DATACENTER_ID
        iD of the Datacenter (required)

    volume_id: --volume VOLUME_ID, -V VOLUME_ID
        iD of the Volume (required)

    name: --name NAME, -n NAME
        name of the data center (required)

    description: --description DESCRIPTION, -d DESCRIPTION
        description of the data center

    licence_type: --licence-type LICENCE_TYPE, -l LICENCE_TYPE
        set to one of the values: [WINDOWS, WINDOWS2016, LINUX, OTHER, UNKNOWN]

    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username (required)

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password (required)

```

## Example

    knife ionoscloud snapshot create --datacenter DATACENTER_ID --volume VOLUME_ID --name NAME --description DESCRIPTION --licence-type LICENCE_TYPE --username USERNAME --password PASSWORD
