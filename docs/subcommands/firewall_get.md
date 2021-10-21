# FirewallGet

Retrieves information about a Ionoscloud Firewall Rule.

```text
knife ionoscloud firewall get (options)
```

## Available options:

### Required options:

* firewall\_id
* datacenter\_id
* server\_id
* nic\_id
* ionoscloud\_username
* ionoscloud\_password

```text
    datacenter_id: --datacenter-id DATACENTER_ID, -D DATACENTER_ID
        the ID of the data center (required)

    server_id: --server-id SERVER_ID, -S SERVER_ID
        the ID of the server (required)

    nic_id: --nic-id NIC_ID, -N NIC_ID
        iD of the NIC (required)

    firewall_id: --firewall-id FIREWALL_ID, -F FIREWALL_ID
        iD of the Firewall Rule (required)

    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username (required)

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password (required)

    extra_config_file: --extra-config EXTRA_CONFIG_FILE_PATH, -e EXTRA_CONFIG_FILE_PATH
        path to the additional config file

```
## Example

```text
knife ionoscloud firewall get --datacenter-id DATACENTER_ID --server-id SERVER_ID --nic-id NIC_ID --firewall-id FIREWALL_ID --username USERNAME --password PASSWORD --extra-config EXTRA_CONFIG_FILE_PATH
```
