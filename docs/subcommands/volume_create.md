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
* ionoscloud\_username
* ionoscloud\_password

```text
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

    image_alias: --image-alias IMAGE_ALIAS
        (required) The image alias

    image_password: --image-password PASSWORD, -P PASSWORD
        the password set on the image for the "root" or "Administrator" user

    type: --type TYPE, -t TYPE
        the disk type (HDD OR SSD) (required)

    licence_type: --licence-type LICENCE, -l LICENCE
        the licence type of the volume (LINUX, WINDOWS, UNKNOWN, OTHER)

    ssh_keys: --ssh-keys SSHKEY1,SSHKEY2,..., -K SSHKEY[,SSHKEY,...]
        a list of public SSH keys to include

    availability_zone: --availability-zone AVAILABILITY_ZONE, -Z AVAILABILITY_ZONE
        the volume availability zone of the server

    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username (required)

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password (required)

```
## Example

```text
knife ionoscloud volume create --datacenter-id DATACENTER_ID --name NAME --size SIZE --bus BUS --image ID --image-alias IMAGE_ALIAS --image-password PASSWORD --type TYPE --licence-type LICENCE --ssh-keys SSHKEY1,SSHKEY2,... --availability-zone AVAILABILITY_ZONE --username USERNAME --password PASSWORD
```
