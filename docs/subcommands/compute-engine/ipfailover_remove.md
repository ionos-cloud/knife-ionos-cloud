# IpfailoverRemove

Remove IP Failover from LAN

```text
knife ionoscloud ipfailover remove (options)
```

## Available options:

### Required options:

* datacenter\_id
* lan\_id
* ip
* nic\_id
* ionoscloud\_username
* ionoscloud\_password

```text
    extra_config_file: --extra-config EXTRA_CONFIG_FILE_PATH, -e EXTRA_CONFIG_FILE_PATH
        path to the additional config file

    datacenter_id: --datacenter-id DATACENTER_ID, -D DATACENTER_ID
        name of the data center (required)

    lan_id: --lan-id LAN_ID, -l LAN_ID
        lan ID (required)

    ip: --ip IP, -i IP
        iP to be removed from the IP failover group (required)

    nic_id: --nic-id NIC_ID, -n NIC_ID
        nIC to be removed from the IP failover group (required)

    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username (required)

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password (required)

    ionoscloud_url: --url URL
        the Ionoscloud API URL

```
## Example

```text
knife ionoscloud ipfailover remove --extra-config EXTRA_CONFIG_FILE_PATH --datacenter-id DATACENTER_ID --lan-id LAN_ID --ip IP --nic-id NIC_ID --username USERNAME --password PASSWORD --url URL
```
