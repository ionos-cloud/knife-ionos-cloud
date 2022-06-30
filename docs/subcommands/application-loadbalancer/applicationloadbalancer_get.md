# ApplicationloadbalancerGet

Retrieves the attributes of a given Application Load Balancer.

```text
knife ionoscloud applicationloadbalancer get (options)
```

## Available options:

### Required options:

* datacenter\_id
* application\_loadbalancer\_id
* ionoscloud\_username
* ionoscloud\_password

```text
    ionoscloud_url: --url URL
        the Ionoscloud API URL

    extra_config_file: --extra-config EXTRA_CONFIG_FILE_PATH, -e EXTRA_CONFIG_FILE_PATH
        path to the additional config file

    datacenter_id: --datacenter-id DATACENTER_ID, -D DATACENTER_ID
        iD of the data center (required)

    application_loadbalancer_id: --application-loadbalancer NETWORK_LOADBALANCER_ID, -L NETWORK_LOADBALANCER_ID
        iD of the Application Loadbalancer (required)

    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username (required)

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password (required)

    ionoscloud_token: --token PASSWORD
        your Ionoscloud access token

```
## Example

```text
knife ionoscloud applicationloadbalancer get --url URL --extra-config EXTRA_CONFIG_FILE_PATH --datacenter-id DATACENTER_ID --application-loadbalancer NETWORK_LOADBALANCER_ID --username USERNAME --password PASSWORD --token PASSWORD
```
