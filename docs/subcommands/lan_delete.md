# LanDelete

Deletes an existing LAN.

```text
knife ionoscloud lan delete LAN_ID [LAN_ID] (options)
```

## Available options:

### Required options:

* datacenter_id
* ionoscloud_username
* ionoscloud_password

```text
    datacenter_id: --datacenter-id DATACENTER_ID, -D DATACENTER_ID
        name of the data center (required)
    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username (required)
    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password (required)
```

## Example

```text
knife ionoscloud lan delete LAN_ID 
```
