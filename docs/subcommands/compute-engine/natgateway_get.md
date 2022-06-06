# NatgatewayGet

Retrieves the attributes of a given NAT Gateway.

```text
knife ionoscloud natgateway get (options)
```

## Available options:

### Required options:

* datacenter\_id
* natgateway\_id

```text
    ionoscloud_url: --url URL
        the Ionoscloud API URL

    extra_config_file: --extra-config EXTRA_CONFIG_FILE_PATH, -e EXTRA_CONFIG_FILE_PATH
        path to the additional config file

    datacenter_id: --datacenter-id DATACENTER_ID, -D DATACENTER_ID
        name of the data center (required)

    natgateway_id: --natgateway-id NATGATEWAY_ID, -G NATGATEWAY_ID
        iD of the NAT Gateway (required)

    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password

    ionoscloud_token: --token PASSWORD
        your Ionoscloud access token

```
## Example

```text
knife ionoscloud natgateway get --url URL --extra-config EXTRA_CONFIG_FILE_PATH --datacenter-id DATACENTER_ID --natgateway-id NATGATEWAY_ID --username USERNAME --password PASSWORD --token PASSWORD
```
