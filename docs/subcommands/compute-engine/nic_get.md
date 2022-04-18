# NicGet

Retrieves the attributes of a given NIC.

```text
knife ionoscloud nic get (options)
```

## Available options:

### Required options:

* datacenter\_id
* server\_id
* nic\_id
* ionoscloud\_username
* ionoscloud\_password

```text
    extra_config_file: --extra-config EXTRA_CONFIG_FILE_PATH, -e EXTRA_CONFIG_FILE_PATH
        path to the additional config file

    datacenter_id: --datacenter-id DATACENTER_ID, -D DATACENTER_ID
        iD of the data center (required)

    server_id: --server-id SERVER_ID, -S SERVER_ID
        the ID of the server to which the NIC is assigned (required)

    nic_id: --nic-id NIC_ID, -N NIC_ID
        iD of the load balancer (required)

    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username (required)

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password (required)

    ionoscloud_url: --url URL
        the Ionoscloud API URL

```
## Example

```text
knife ionoscloud nic get --extra-config EXTRA_CONFIG_FILE_PATH --datacenter-id DATACENTER_ID --server-id SERVER_ID --nic-id NIC_ID --username USERNAME --password PASSWORD --url URL
```
