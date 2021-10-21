# VolumeUpdate

Updates information about a Ionoscloud Volume.

```text
knife ionoscloud volume update (options)
```

## Available options:

### Required options:

* datacenter\_id
* volume\_id
* ionoscloud\_username
* ionoscloud\_password

```text
    datacenter_id: --datacenter-id DATACENTER_ID, -D DATACENTER_ID
        name of the data center (required)

    volume_id: --volume VOLUME_ID
        iD of the Volume. (required)

    name: --name NAME, -n NAME
        name of the volume

    size: --size SIZE, -S SIZE
        the size of the volume in GB

    bus: --bus BUS, -b BUS
        the bus type of the volume (VIRTIO or IDE)

    cpu_hot_plug: --cpu-hot-plug CPU_HOT_PLUG
        the licence type of the volume (LINUX, WINDOWS, UNKNOWN, OTHER)

    ram_hot_plug: --ram-hot-plug RAM_HOT_PLUG
        the licence type of the volume (LINUX, WINDOWS, UNKNOWN, OTHER)

    nic_hot_plug: --nic-hot-plug NIC_HOT_PLUG
        the licence type of the volume (LINUX, WINDOWS, UNKNOWN, OTHER)

    nic_hot_unplug: --nic-hot-unplug NIC_HOT_UNPLUG
        the licence type of the volume (LINUX, WINDOWS, UNKNOWN, OTHER)

    disc_virtio_hot_plug: --disc-virtio-hot_plug DISC_VIRTIO_HOT_PLUG
        the licence type of the volume (LINUX, WINDOWS, UNKNOWN, OTHER)

    disc_virtio_hot_unplug: --disc-virtio-hot_unplug DISC_VIRTIO_HOT_UNPLUG
        the licence type of the volume (LINUX, WINDOWS, UNKNOWN, OTHER)

    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username (required)

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password (required)

    extra_config_file: --extra-config EXTRA_CONFIG_FILE_PATH, -e EXTRA_CONFIG_FILE_PATH
        path to the additional config file

```
## Example

```text
knife ionoscloud volume update --datacenter-id DATACENTER_ID --volume VOLUME_ID --name NAME --size SIZE --bus BUS --cpu-hot-plug CPU_HOT_PLUG --ram-hot-plug RAM_HOT_PLUG --nic-hot-plug NIC_HOT_PLUG --nic-hot-unplug NIC_HOT_UNPLUG --disc-virtio-hot_plug DISC_VIRTIO_HOT_PLUG --disc-virtio-hot_unplug DISC_VIRTIO_HOT_UNPLUG --username USERNAME --password PASSWORD --extra-config EXTRA_CONFIG_FILE_PATH
```
