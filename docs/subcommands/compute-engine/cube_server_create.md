# CubeServerCreate

This creates a new cube server with an attached volume and NIC in a specified virtual data center.

```text
knife ionoscloud cube server create (options)
```

## Available options:

### Required options:

* datacenter\_id
* name
* template

```text
    ionoscloud_url: --url URL
        the Ionoscloud API URL

    extra_config_file: --extra-config EXTRA_CONFIG_FILE_PATH, -e EXTRA_CONFIG_FILE_PATH
        path to the additional config file

    datacenter_id: --datacenter-id DATACENTER_ID, -D DATACENTER_ID
        name of the virtual datacenter (required)

    name: --name NAME, -n NAME
        (required) Name of the server (required)

    template: --template TEMPLATE_UUID
        the UUID of the template for creating a CUBE server; the available templates for CUBE servers can be found on the templates resource (required)

    cpu_family: --cpu-family CPU_FAMILY, -f CPU_FAMILY
        the family of processor cores (INTEL_XEON or AMD_OPTERON)

    availability_zone: --availability-zone AVAILABILITY_ZONE, -a AVAILABILITY_ZONE
        the availability zone of the server

    volume_name: --volume-name NAME
        name of the volume

    bus: --bus BUS, -b BUS
        the bus type of the volume (VIRTIO or IDE)

    image: --image ID, -N ID
        (required) The image or snapshot ID

    licence_type: --licence-type LICENCE, -l LICENCE
        the licence type of the volume (LINUX, WINDOWS, WINDOWS2016, UNKNOWN, OTHER)

    image_password: --image-password PASSWORD, -P PASSWORD
        the password set on the image for the "root" or "Administrator" user

    ssh_keys: --ssh-keys SSHKEY1,SSHKEY2,..., -K SSHKEY[,SSHKEY,...]
        a list of public SSH keys to include

    backupunit_id: --backupunit BACKUPUNIT_ID, -B BACKUPUNIT_ID
        the uuid of the Backup Unit that user has access to. The property is immutable and is only allowed to be set on a new volume creation. It is mandatory to provide either 'public image' or 'imageAlias' in conjunction with this property.

    user_data: --user-data USER_DATA, -u USER_DATA
        the cloud-init configuration for the volume as base64 encoded string. The property is immutable and is only allowed to be set on a new volume creation. It is mandatory to provide either 'public image' or 'imageAlias' that has cloud-init compatibility in conjunction with this property.

    set_boot: --set-boot
        whether to set the volume as the boot volume

    nic_name: --nic-name NAME
        name of the NIC

    ips: --ips IP[,IP,...], -i IP[,IP,...]
        iPs assigned to the NIC

    dhcp: --dhcp, -h
        set to false if you wish to disable DHCP

    lan: --lan ID, -L ID
        the LAN ID the NIC will reside on; if the LAN ID does not exist it will be created

    firewall_type: --firewall-type FIREWALL_TYPE, -t FIREWALL_TYPE
        the type of firewall rules that will be allowed on the NIC. If it is not specified it will take the default value INGRESS

    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password

    ionoscloud_token: --token PASSWORD
        your Ionoscloud access token

```
## Example

```text
knife ionoscloud cube server create --url URL --extra-config EXTRA_CONFIG_FILE_PATH --datacenter-id DATACENTER_ID --name NAME --template TEMPLATE_UUID --cpu-family CPU_FAMILY --availability-zone AVAILABILITY_ZONE --volume-name NAME --bus BUS --image ID --licence-type LICENCE --image-password PASSWORD --ssh-keys SSHKEY1,SSHKEY2,... --backupunit BACKUPUNIT_ID --user-data USER_DATA --set-boot --nic-name NAME --ips IP[,IP,...] --dhcp --lan ID --firewall-type FIREWALL_TYPE --username USERNAME --password PASSWORD --token PASSWORD
```
