# PccCreate

Creates a Private Cross-Connect.

    knife ionoscloud pcc create (options)


## Available options:
---

### Required options:
* name
* peers
* datacenters
* ionoscloud_username
* ionoscloud_password

```
    name: --name NAME, -n NAME
        name of the data center (required)

    description: --description DESCRIPTION, -D DESCRIPTION
        description of the data center

    peers: --peers LAN_ID [LAN_ID]
        an array of LANs joined to this private cross connect (required)

    datacenters: --datacenters DATACENTER_IS [DATACENTER_IS]
        an array of datacenters joined to this private cross connect (required)

    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username (required)

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password (required)

```

## Example

    knife ionoscloud pcc create --name NAME --description DESCRIPTION --peers LAN_ID [LAN_ID] --datacenters DATACENTER_IS [DATACENTER_IS] --username USERNAME --password PASSWORD
