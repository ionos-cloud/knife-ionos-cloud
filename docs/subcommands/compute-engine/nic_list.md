# NicList

List all available NICs connected to a server.

```text
knife ionoscloud nic list (options)
```

## Available options:

### Required options:

* datacenter\_id
* server\_id

```text
    ionoscloud_url: --url URL
        the Ionoscloud API URL

    extra_config_file: --extra-config EXTRA_CONFIG_FILE_PATH, -e EXTRA_CONFIG_FILE_PATH
        path to the additional config file

    datacenter_id: --datacenter-id DATACENTER_ID, -D DATACENTER_ID
        the ID of the datacenter containing the NIC (required)

    server_id: --server-id SERVER_ID, -S SERVER_ID
        the ID of the server assigned the NIC (required)

    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password

    ionoscloud_token: --token PASSWORD
        your Ionoscloud access token

```
## Example

```text
knife ionoscloud nic list --url URL --extra-config EXTRA_CONFIG_FILE_PATH --datacenter-id DATACENTER_ID --server-id SERVER_ID --username USERNAME --password PASSWORD --token PASSWORD
```
