# VolumeList

List all available volumes under a data center. You can also list all volumes attached to a specific server.

```text
knife ionoscloud volume list (options)
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
        the ID of the virtul data center containing the volume (required)

    server_id: --server-id SERVER_ID, -S SERVER_ID
        the ID of the server

    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password

    ionoscloud_token: --token PASSWORD
        your Ionoscloud access token

```
## Example

```text
knife ionoscloud volume list --url URL --extra-config EXTRA_CONFIG_FILE_PATH --datacenter-id DATACENTER_ID --server-id SERVER_ID --username USERNAME --password PASSWORD --token PASSWORD
```
