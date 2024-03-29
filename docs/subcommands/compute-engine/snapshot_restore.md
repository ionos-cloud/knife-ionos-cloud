# SnapshotRestore

This will restore a snapshot onto a volume. A snapshot is created as just another image that can be used to create new volumes or to restore an existing volume.

```text
knife ionoscloud snapshot restore (options)
```

## Available options:

### Required options:

* datacenter\_id
* volume\_id
* snapshot\_id

```text
    ionoscloud_url: --url URL
        the Ionoscloud API URL

    extra_config_file: --extra-config EXTRA_CONFIG_FILE_PATH, -e EXTRA_CONFIG_FILE_PATH
        path to the additional config file

    datacenter_id: --datacenter DATACENTER_ID, -D DATACENTER_ID
        iD of the Datacenter (required)

    volume_id: --volume VOLUME_ID, -V VOLUME_ID
        iD of the Volume (required)

    snapshot_id: --snapshot SNAPSHOT_ID, -S SNAPSHOT_ID
        iD of the Snapshot (required)

    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password

    ionoscloud_token: --token PASSWORD
        your Ionoscloud access token

```
## Example

```text
knife ionoscloud snapshot restore --url URL --extra-config EXTRA_CONFIG_FILE_PATH --datacenter DATACENTER_ID --volume VOLUME_ID --snapshot SNAPSHOT_ID --username USERNAME --password PASSWORD --token PASSWORD
```
