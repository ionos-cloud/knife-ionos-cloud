# SnapshotUpdate

Updates information about a Ionoscloud Snapshot.

```text
knife ionoscloud snapshot update (options)
```

## Available options:

### Required options:

* snapshot\_id

```text
    ionoscloud_url: --url URL
        the Ionoscloud API URL

    extra_config_file: --extra-config EXTRA_CONFIG_FILE_PATH, -e EXTRA_CONFIG_FILE_PATH
        path to the additional config file

    snapshot_id: --snapshot-id SNAPSHOT_ID, -S SNAPSHOT_ID
        iD of the Snapshot. (required)

    name: --name NAME, -n NAME
        name of the server

    description: --description DESCRIPTION
        the number of processor cores

    sec_auth_protection: --sec-auth-protection SEC_AUTH_PROTECTION
        boolean value representing if the snapshot requires extra protection e.g. two factor protection

    licence_type: --licence-type LICENCE, -l LICENCE
        the licence type of the snapshot (LINUX, WINDOWS, UNKNOWN, OTHER)

    cpu_hot_plug: --cpu-hot-plug CPU_HOT_PLUG
        the licence type of the snapshot (LINUX, WINDOWS, UNKNOWN, OTHER)

    cpu_hot_unplug: --cpu-hot-unplug CPU_HOT_UNPLUG
        the licence type of the snapshot (LINUX, WINDOWS, UNKNOWN, OTHER)

    ram_hot_plug: --ram-hot-plug RAM_HOT_PLUG
        the licence type of the snapshot (LINUX, WINDOWS, UNKNOWN, OTHER)

    ram_hot_unplug: --ram-hot-unplug RAM_HOT_UNPLUG
        the licence type of the snapshot (LINUX, WINDOWS, UNKNOWN, OTHER)

    nic_hot_plug: --nic-hot-plug NIC_HOT_PLUG
        the licence type of the snapshot (LINUX, WINDOWS, UNKNOWN, OTHER)

    nic_hot_unplug: --nic-hot-unplug NIC_HOT_UNPLUG
        the licence type of the snapshot (LINUX, WINDOWS, UNKNOWN, OTHER)

    disc_virtio_hot_plug: --disc-virtio-hot_plug DISC_VIRTIO_HOT_PLUG
        the licence type of the snapshot (LINUX, WINDOWS, UNKNOWN, OTHER)

    disc_virtio_hot_unplug: --disc-virtio-hot_unplug DISC_VIRTIO_HOT_UNPLUG
        the licence type of the snapshot (LINUX, WINDOWS, UNKNOWN, OTHER)

    disc_scsi_hot_plug: --disc-scsi-hot-plug DISC_SCSI_HOT_PLUG
        the licence type of the snapshot (LINUX, WINDOWS, UNKNOWN, OTHER)

    disc_scsi_hot_unplug: --disc-scsi-hot-unplug DISC_SCSI_HOT_UNPLUG
        the licence type of the snapshot (LINUX, WINDOWS, UNKNOWN, OTHER)

    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password

    ionoscloud_token: --token PASSWORD
        your Ionoscloud access token

```
## Example

```text
knife ionoscloud snapshot update --url URL --extra-config EXTRA_CONFIG_FILE_PATH --snapshot-id SNAPSHOT_ID --name NAME --description DESCRIPTION --sec-auth-protection SEC_AUTH_PROTECTION --licence-type LICENCE --cpu-hot-plug CPU_HOT_PLUG --cpu-hot-unplug CPU_HOT_UNPLUG --ram-hot-plug RAM_HOT_PLUG --ram-hot-unplug RAM_HOT_UNPLUG --nic-hot-plug NIC_HOT_PLUG --nic-hot-unplug NIC_HOT_UNPLUG --disc-virtio-hot_plug DISC_VIRTIO_HOT_PLUG --disc-virtio-hot_unplug DISC_VIRTIO_HOT_UNPLUG --disc-scsi-hot-plug DISC_SCSI_HOT_PLUG --disc-scsi-hot-unplug DISC_SCSI_HOT_UNPLUG --username USERNAME --password PASSWORD --token PASSWORD
```
