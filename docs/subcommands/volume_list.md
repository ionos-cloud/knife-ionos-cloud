# VolumeList

List all available volumes under a data center. You can also list all volumes attached to a specific server.

```text
knife ionoscloud volume list (options)
```

## Available options:

### Required options:

* datacenter\_id
* ionoscloud\_username
* ionoscloud\_password

```text
    datacenter_id: --datacenter-id DATACENTER_ID, -D DATACENTER_ID
        the ID of the virtul data center containing the volume (required)

    server_id: --server-id SERVER_ID, -S SERVER_ID
        the ID of the server

    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username (required)

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password (required)

    extra_config_file: --extra-config EXTRA_CONFIG_FILE, -e EXTRA_CONFIG_FILE
        additional config file name

```
## Example

```text
knife ionoscloud volume list --datacenter-id DATACENTER_ID --server-id SERVER_ID --username USERNAME --password PASSWORD --extra-config EXTRA_CONFIG_FILE
```
