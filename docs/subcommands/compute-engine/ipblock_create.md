# IpblockCreate

Reserves an IP block at a specified location that can be used by resources within any VDCs provisioned in that same location. An IP block consists of one or more static IP addresses. The IP block size \(number of IP addresses\) and location are required to reserve an IP block.

```text
knife ionoscloud ipblock create (options)
```

## Available options:

### Required options:

* size
* location

```text
    ionoscloud_url: --url URL
        the Ionoscloud API URL

    extra_config_file: --extra-config EXTRA_CONFIG_FILE_PATH, -e EXTRA_CONFIG_FILE_PATH
        path to the additional config file

    location: --location LOCATION, -l LOCATION
        location of the IP block (us/las, us/ewr, de/fra, de/fkb) (required)

    size: --size INT, -S INT
        the number of IP addresses to reserve (required)

    name: --name NAME, -n NAME
        name of the IP block

    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password

    ionoscloud_token: --token PASSWORD
        your Ionoscloud access token

```
## Example

```text
knife ionoscloud ipblock create --url URL --extra-config EXTRA_CONFIG_FILE_PATH --location LOCATION --size INT --name NAME --username USERNAME --password PASSWORD --token PASSWORD
```
