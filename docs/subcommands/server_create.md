# ServerCreate



    knife ionoscloud server create (options)


## Available options:

```
* ionoscloud_username: --username USERNAME, -u USERNAME   Your Ionoscloud username
* ionoscloud_password: --password PASSWORD, -p PASSWORD   Your Ionoscloud password
* datacenter_id: --datacenter-id DATACENTER_ID, -D DATACENTER_ID   Name of the virtual datacenter
* name: --name NAME, -n NAME   Name of the server
* cores: --cores CORES, -C CORES   The number of processor cores
* cpufamily: --cpu-family CPU_FAMILY, -f CPU_FAMILY   The family of the CPU (INTEL_XEON or AMD_OPTERON)
* ram: --ram RAM, -r RAM   The amount of RAM in MB
* availabilityzone: --availability-zone AVAILABILITY_ZONE, -a AVAILABILITY_ZONE   The availability zone of the server
* bootvolume: --boot-volume VOLUME_ID,    Reference to a volume used for booting
* bootcdrom: --boot-cdrom CDROM_ID,    Reference to a CD-ROM used for booting
```

## Example

    knife ionoscloud server create --username USERNAME --password PASSWORD --datacenter-id DATACENTER_ID --name NAME --cores CORES --cpu-family CPU_FAMILY --ram RAM --availability-zone AVAILABILITY_ZONE --boot-volume VOLUME_ID --boot-cdrom CDROM_ID
