# ServerUpgrade

This will upgrade the version of the server, if needed. To verify if there is an upgrade available for a server, call '/datacenters/{datacenterId}/servers?upgradeNeeded=true'.

```text
knife ionoscloud server upgrade (options)
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

    extra_config_file: --extra-config EXTRA_CONFIG_FILE_PATH, -e EXTRA_CONFIG_FILE_PATH
        path to the additional config file

```
## Example

```text
knife ionoscloud server upgrade --datacenter-id DATACENTER_ID --server-id SERVER_ID --username USERNAME --password PASSWORD --extra-config EXTRA_CONFIG_FILE_PATH
```
