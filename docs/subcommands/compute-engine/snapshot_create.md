# SnapshotCreate

Creates a snapshot of a volume within the virtual data center. You can use a snapshot to create a new storage volume or to restore a storage volume.

```text
knife ionoscloud snapshot create (options)
```

## Available options:

### Required options:

* datacenter\_id
* volume\_id

```text
    ionoscloud_url: --url URL
        the Ionoscloud API URL

    extra_config_file: --extra-config EXTRA_CONFIG_FILE_PATH, -e EXTRA_CONFIG_FILE_PATH
        path to the additional config file

    datacenter_id: --datacenter DATACENTER_ID, -D DATACENTER_ID
        iD of the Datacenter (required)

    volume_id: --volume VOLUME_ID, -V VOLUME_ID
        iD of the Volume (required)

    name: --name SNAPSHOT_NAME, -n SNAPSHOT_NAME
        name of the snapshot

    description: --description SNAPSHOT_DESCRIPTION
        description of the snapshot

    sec_auth_protection: --sec-auth
        flag representing if extra protection is enabled on snapshot e.g. Two Factor protection etc.

    licence_type: --licence LICENCE_TYPE, -l LICENCE_TYPE
        the OS type of this Snapshot

    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password

    ionoscloud_token: --token PASSWORD
        your Ionoscloud access token

```
## Example

```text
knife ionoscloud snapshot create --url URL --extra-config EXTRA_CONFIG_FILE_PATH --datacenter DATACENTER_ID --volume VOLUME_ID --name SNAPSHOT_NAME --description SNAPSHOT_DESCRIPTION --sec-auth --licence LICENCE_TYPE --username USERNAME --password PASSWORD --token PASSWORD
```
