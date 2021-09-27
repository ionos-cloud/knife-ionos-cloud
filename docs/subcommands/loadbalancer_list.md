# LoadbalancerList

Retrieve a list of load balancers within the virtual data center.

```text
knife ionoscloud loadbalancer list (options)
```

## Available options:

### Required options:

* datacenter\_id
* ionoscloud\_username
* ionoscloud\_password

```text
    datacenter_id: --datacenter-id DATACENTER_ID, -D DATACENTER_ID
        name of the data center (required)

    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username (required)

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password (required)

    extra_config_file: --extra-config EXTRA_CONFIG_FILE_PATH, -e EXTRA_CONFIG_FILE_PATH
        path to the additional config file

```
## Example

```text
knife ionoscloud loadbalancer list --datacenter-id DATACENTER_ID --username USERNAME --password PASSWORD --extra-config EXTRA_CONFIG_FILE_PATH
```
