# IpblockCreate



    knife ionoscloud ipblock create (options)


## Available options:

```
    ionoscloud_username: --username USERNAME, -u USERNAME
        Your Ionoscloud username

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        Your Ionoscloud password

    location: --location LOCATION, -l LOCATION
        Location of the IP block (us/las, us/ewr, de/fra, de/fkb)

    size: --size INT, -S INT
        The number of IP addresses to reserve

    name: --name NAME, -n NAME
        Name of the IP block

```

## Example

    knife ionoscloud ipblock create --username USERNAME --password PASSWORD --location LOCATION --size INT --name NAME
