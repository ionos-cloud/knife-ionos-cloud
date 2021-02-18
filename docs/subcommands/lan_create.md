# LanCreate

Creates a new LAN under a data center.

    knife ionoscloud lan create (options)


## Available options:
---

### Required options:
* datacenter_id

```
    datacenter_id: --datacenter-id DATACENTER_ID, -D DATACENTER_ID
        name of the data center (required)

    name: --name NAME, -n NAME
        name of the server

    public: --public, -p
        boolean indicating if the LAN faces the public Internet or not; defaults to false

    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password

```

## Example

    knife ionoscloud lan create --datacenter-id DATACENTER_ID --name NAME --public --username USERNAME --password PASSWORD