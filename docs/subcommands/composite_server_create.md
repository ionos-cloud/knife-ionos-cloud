# CompositeServerCreate

This creates a new composite server with an attached volume and NIC in a specified virtual data center.

```text
knife ionoscloud composite server create (options)
```

## Available options:

### Required options:

* datacenter\_id
* name
* cores
* ram
* size
* type
* dhcp
* lan
* ionoscloud\_username
* ionoscloud\_password

```text
    datacenter_id: --datacenter-id DATACENTER_ID, -D DATACENTER_ID
        name of the virtual datacenter (required)

    name: --name NAME, -n NAME
        (required) Name of the server (required)

    cores: --cores CORES, -C CORES
        (required) The number of processor cores (required)

    cpu_family: --cpu-family CPU_FAMILY, -f CPU_FAMILY
        the family of processor cores (INTEL_XEON or AMD_OPTERON)

    ram: --ram RAM, -r RAM
        (required) The amount of RAM in MB (required)

    availability_zone: --availability-zone AVAILABILITY_ZONE, -a AVAILABILITY_ZONE
        the availability zone of the server

    volume_name: --volume-name NAME
        name of the volume

    size: --size SIZE, -S SIZE
        (required) The size of the volume in GB (required)

    bus: --bus BUS, -b BUS
        the bus type of the volume (VIRTIO or IDE)

    image: --image ID, -N ID
        (required) The image or snapshot ID

    image_alias: --image-alias IMAGE_ALIAS
        (required) The image alias

    type: --type TYPE, -t TYPE
        (required) The disk type (HDD or SSD) (required)

    licence_type: --licence-type LICENCE, -l LICENCE
        the licence type of the volume (LINUX, WINDOWS, WINDOWS2016, UNKNOWN, OTHER)

    image_password: --image-password PASSWORD, -P PASSWORD
        the password set on the image for the "root" or "Administrator" user

    volume_availability_zone: --volume-availability-zone AVAILABILITY_ZONE, -Z AVAILABILITY_ZONE
        the volume availability zone of the server

    ssh_keys: --ssh-keys SSHKEY1,SSHKEY2,..., -K SSHKEY[,SSHKEY,...]
        a list of public SSH keys to include

    nic_name: --nic-name NAME
        name of the NIC

    ips: --ips IP[,IP,...], -i IP[,IP,...]
        iPs assigned to the NIC

    dhcp: --dhcp, -h
        set to false if you wish to disable DHCP (required)

    lan: --lan ID, -L ID
        the LAN ID the NIC will reside on; if the LAN ID does not exist it will be created (required)

    nat: --nat
        set to enable NAT on the NIC

    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username (required)

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password (required)

    extra_config_file: --extra-config EXTRA_CONFIG_FILE_PATH, -e EXTRA_CONFIG_FILE_PATH
        path to the additional config file

```
## Example

```text
knife ionoscloud composite server create --datacenter-id DATACENTER_ID --name NAME --cores CORES --cpu-family CPU_FAMILY --ram RAM --availability-zone AVAILABILITY_ZONE --volume-name NAME --size SIZE --bus BUS --image ID --image-alias IMAGE_ALIAS --type TYPE --licence-type LICENCE --image-password PASSWORD --volume-availability-zone AVAILABILITY_ZONE --ssh-keys SSHKEY1,SSHKEY2,... --nic-name NAME --ips IP[,IP,...] --dhcp --lan ID --nat --username USERNAME --password PASSWORD --extra-config EXTRA_CONFIG_FILE_PATH
```
