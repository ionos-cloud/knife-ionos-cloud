# CompositeServerCreate



    knife ionoscloud composite server create (options)


## Available options:

```
    ionoscloud_username: --username USERNAME, -u USERNAME
        Your Ionoscloud username

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        Your Ionoscloud password

    datacenter_id: --datacenter-id DATACENTER_ID, -D DATACENTER_ID
        Name of the virtual datacenter

    name: --name NAME, -n NAME
        (required) Name of the server

    cores: --cores CORES, -C CORES
        (required) The number of processor cores

    cpufamily: --cpu-family CPU_FAMILY, -f CPU_FAMILY
        The family of processor cores (INTEL_XEON or AMD_OPTERON)

    ram: --ram RAM, -r RAM
        (required) The amount of RAM in MB

    availabilityzone: --availability-zone AVAILABILITY_ZONE, -a AVAILABILITY_ZONE
        The availability zone of the server

    volumename: --volume-name NAME
        Name of the volume

    size: --size SIZE, -S SIZE
        (required) The size of the volume in GB

    bus: --bus BUS, -b BUS
        The bus type of the volume (VIRTIO or IDE)

    image: --image ID, -N ID
        (required) The image or snapshot ID

    imagealias: --image-alias IMAGE_ALIAS
        (required) The image alias

    type: --type TYPE, -t TYPE
        (required) The disk type (HDD or SSD)

    licencetype: --licence-type LICENCE, -l LICENCE
        The licence type of the volume (LINUX, WINDOWS, WINDOWS2016, UNKNOWN, OTHER)

    imagepassword: --image-password PASSWORD, -P PASSWORD
        The password set on the image for the &quot;root&quot; or &quot;Administrator&quot; user

    volume_availability_zone: --volume-availability-zone AVAILABILITY_ZONE, -Z AVAILABILITY_ZONE
        The volume availability zone of the server

    sshkeys: --ssh-keys SSHKEY1,SSHKEY2,..., -K SSHKEY[,SSHKEY,...]
        A list of public SSH keys to include

    nicname: --nic-name NAME
        Name of the NIC

    ips: --ips IP[,IP,...], -i IP[,IP,...]
        IPs assigned to the NIC

    dhcp: --dhcp, -h
        (required) Set to false if you wish to disable DHCP

    lan: --lan ID, -L ID
        The LAN ID the NIC will reside on; if the LAN ID does not exist it will be created

    nat: --nat
        Set to enable NAT on the NIC

```

## Example

    knife ionoscloud composite server create --username USERNAME --password PASSWORD --datacenter-id DATACENTER_ID --name NAME --cores CORES --cpu-family CPU_FAMILY --ram RAM --availability-zone AVAILABILITY_ZONE --volume-name NAME --size SIZE --bus BUS --image ID --image-alias IMAGE_ALIAS --type TYPE --licence-type LICENCE --image-password PASSWORD --volume-availability-zone AVAILABILITY_ZONE --ssh-keys SSHKEY1,SSHKEY2,... --nic-name NAME --ips IP[,IP,...] --dhcp --lan ID --nat
