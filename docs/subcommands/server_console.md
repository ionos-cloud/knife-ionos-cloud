# ServerConsole

Returns the link with the jwToken to access the server remote console.

```text
knife ionoscloud server console (options)
```

## Available options:

### Required options:

* datacenter\_id
* server\_id
* ionoscloud\_username
* ionoscloud\_password

```text
    datacenter_id: --datacenter-id DATACENTER_ID, -D DATACENTER_ID
        the ID of the Datacenter. (required)

    server_id: --server-id SERVER_ID, -S SERVER_ID
        the ID of the Server. (required)

    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username (required)

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password (required)

    extra_config_file: --extra-config EXTRA_CONFIG_FILE, -e EXTRA_CONFIG_FILE
        additional config file name

```
## Example

```text
knife ionoscloud server console --datacenter-id DATACENTER_ID --server-id SERVER_ID --username USERNAME --password PASSWORD --extra-config EXTRA_CONFIG_FILE
```
