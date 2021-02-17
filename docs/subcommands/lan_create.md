# LanCreate



    knife ionoscloud lan create (options)


## Available options:

```
    ionoscloud_username: --username USERNAME, -u USERNAME
        Your Ionoscloud username

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        Your Ionoscloud password

    datacenter_id: --datacenter-id DATACENTER_ID, -D DATACENTER_ID
        Name of the data center

    name: --name NAME, -n NAME
        Name of the server

    public: --public, -p
        Boolean indicating if the LAN faces the public Internet or not; defaults to false

```

## Example

    knife ionoscloud lan create --username USERNAME --password PASSWORD --datacenter-id DATACENTER_ID --name NAME --public
