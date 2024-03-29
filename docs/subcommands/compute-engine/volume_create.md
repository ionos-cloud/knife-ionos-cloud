# VolumeCreate

Creates a volume within the data center. This will NOT attach the volume to a server. Please see the Servers section for details on how to attach storage volumes.

```text
knife ionoscloud volume create (options)
```

## Available options:

### Required options:

* datacenter\_id
* name
* type
* size

```text
    ionoscloud_url: --url URL
        the Ionoscloud API URL

    extra_config_file: --extra-config EXTRA_CONFIG_FILE_PATH, -e EXTRA_CONFIG_FILE_PATH
        path to the additional config file

    datacenter_id: --datacenter-id DATACENTER_ID, -D DATACENTER_ID
        name of the data center (required)

    name: --name NAME, -n NAME
        name of the volume (required)

    size: --size SIZE, -S SIZE
        the size of the volume in GB (required)

    bus: --bus BUS, -b BUS
        the bus type of the volume (VIRTIO or IDE)

    image: --image ID, -N ID
        the image or snapshot ID

    image_password: --image-password PASSWORD, -P PASSWORD
        the password set on the image for the "root" or "Administrator" user

    type: --type TYPE, -t TYPE
        the disk type (HDD, SSD, SSD Standard, SSD Premium, DAS) (required)

    licence_type: --licence-type LICENCE, -l LICENCE
        the licence type of the volume (LINUX, WINDOWS, UNKNOWN, OTHER)

    ssh_keys: --ssh-keys SSHKEY1,SSHKEY2,..., -K SSHKEY[,SSHKEY,...]
        a list of public SSH keys to include

    availability_zone: --availability-zone AVAILABILITY_ZONE, -Z AVAILABILITY_ZONE
        the volume availability zone of the server

    backupunit_id: --backupunit BACKUPUNIT_ID, -B BACKUPUNIT_ID
        the uuid of the Backup Unit that user has access to. The property is immutable and is only allowed to be set on a new volume creation. It is mandatory to provide either 'public image' or 'imageAlias' in conjunction with this property.

    user_data: --user-data USER_DATA, -u USER_DATA
        the cloud-init configuration for the volume as base64 encoded string. The property is immutable and is only allowed to be set on a new volume creation. It is mandatory to provide either 'public image' or 'imageAlias' that has cloud-init compatibility in conjunction with this property.

    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password

    ionoscloud_token: --token PASSWORD
        your Ionoscloud access token

```
## Example

```text
knife ionoscloud volume create --url URL --extra-config EXTRA_CONFIG_FILE_PATH --datacenter-id DATACENTER_ID --name NAME --size SIZE --bus BUS --image ID --image-password PASSWORD --type TYPE --licence-type LICENCE --ssh-keys SSHKEY1,SSHKEY2,... --availability-zone AVAILABILITY_ZONE --backupunit BACKUPUNIT_ID --user-data USER_DATA --username USERNAME --password PASSWORD --token PASSWORD
```
