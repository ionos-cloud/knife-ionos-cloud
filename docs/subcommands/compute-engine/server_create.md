# ServerCreate

One of the unique features of the Ionoscloud platform when compared with the other providers is that they allow you to define your own settings for cores, memory, and disk size without being tied to a particular size or flavor.

Note: _The memory parameter value must be a multiple of 256, e.g. 256, 512, 768, 1024, and so forth._

```text
knife ionoscloud server create (options)
```

## Available options:

### Required options:

* datacenter\_id
* cores
* ram

```text
    ionoscloud_url: --url URL
        the Ionoscloud API URL

    extra_config_file: --extra-config EXTRA_CONFIG_FILE_PATH, -e EXTRA_CONFIG_FILE_PATH
        path to the additional config file

    datacenter_id: --datacenter-id DATACENTER_ID, -D DATACENTER_ID
        name of the virtual datacenter (required)

    name: --name NAME, -n NAME
        name of the server

    cores: --cores CORES, -C CORES
        the number of processor cores (required)

    cpu_family: --cpu-family CPU_FAMILY, -f CPU_FAMILY
        the family of the CPU (INTEL_XEON or AMD_OPTERON)

    ram: --ram RAM, -r RAM
        the amount of RAM in MB (required)

    availability_zone: --availability-zone AVAILABILITY_ZONE, -a AVAILABILITY_ZONE
        the availability zone of the server

    boot_volume: --boot-volume VOLUME_ID
        reference to a volume used for booting

    boot_cdrom: --boot-cdrom CDROM_ID
        reference to a CD-ROM used for booting

    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password

    ionoscloud_token: --token PASSWORD
        your Ionoscloud access token

```
## Example

```text
knife ionoscloud server create --url URL --extra-config EXTRA_CONFIG_FILE_PATH --datacenter-id DATACENTER_ID --name NAME --cores CORES --cpu-family CPU_FAMILY --ram RAM --availability-zone AVAILABILITY_ZONE --boot-volume VOLUME_ID --boot-cdrom CDROM_ID --username USERNAME --password PASSWORD --token PASSWORD
```
