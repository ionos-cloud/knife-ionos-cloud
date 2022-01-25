# ServerUpdate

Updates information about a Ionoscloud Server.

```text
knife ionoscloud server update (options)
```

## Available options:

### Required options:

* datacenter\_id
* server\_id
* ionoscloud\_username
* ionoscloud\_password

```text
    extra_config_file: --extra-config EXTRA_CONFIG_FILE_PATH, -e EXTRA_CONFIG_FILE_PATH
        path to the additional config file

    datacenter_id: --datacenter-id DATACENTER_ID, -D DATACENTER_ID
        iD of the data center (required)

    server_id: --server-id SERVER_ID, -S SERVER_ID
        the ID of the server to which the NIC is assigned (required)

    name: --name NAME, -n NAME
        name of the server

    cores: --cores CORES, -C CORES
        the number of processor cores

    cpu_family: --cpu-family CPU_FAMILY, -f CPU_FAMILY
        the family of the CPU (INTEL_XEON or AMD_OPTERON)

    ram: --ram RAM, -r RAM
        the amount of RAM in MB

    availability_zone: --availability-zone AVAILABILITY_ZONE, -a AVAILABILITY_ZONE
        the availability zone of the server

    boot_volume: --boot-volume VOLUME_ID
        reference to a volume used for booting

    boot_cdrom: --boot-cdrom CDROM_ID
        reference to a CD-ROM used for booting

    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username (required)

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password (required)

    ionoscloud_url: --url URL
        the Ionoscloud API URL

```
## Example

```text
knife ionoscloud server update --extra-config EXTRA_CONFIG_FILE_PATH --datacenter-id DATACENTER_ID --server-id SERVER_ID --name NAME --cores CORES --cpu-family CPU_FAMILY --ram RAM --availability-zone AVAILABILITY_ZONE --boot-volume VOLUME_ID --boot-cdrom CDROM_ID --username USERNAME --password PASSWORD --url URL
```
