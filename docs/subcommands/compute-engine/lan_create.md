# LanCreate

Creates a new LAN under a data center.

```text
knife ionoscloud lan create (options)
```

## Available options:

### Required options:

* datacenter\_id

```text
    ionoscloud_url: --url URL
        the Ionoscloud API URL

    extra_config_file: --extra-config EXTRA_CONFIG_FILE_PATH, -e EXTRA_CONFIG_FILE_PATH
        path to the additional config file

    datacenter_id: --datacenter-id DATACENTER_ID, -D DATACENTER_ID
        name of the data center (required)

    name: --name NAME, -n NAME
        name of the server

    public: --public, -p
        boolean indicating if the LAN faces the public Internet or not; defaults to false

    pcc: --pcc PCC_ID
        iD of the PCC to connect the LAN to

    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password

    ionoscloud_token: --token PASSWORD
        your Ionoscloud access token

```
## Example

```text
knife ionoscloud lan create --url URL --extra-config EXTRA_CONFIG_FILE_PATH --datacenter-id DATACENTER_ID --name NAME --public --pcc PCC_ID --username USERNAME --password PASSWORD --token PASSWORD
```
