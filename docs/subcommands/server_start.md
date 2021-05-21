# ServerStart

This will start a server. If the server's public IP was deallocated then a new IP will be assigned.

```text
knife ionoscloud server start SERVER_ID [SERVER_ID] (options)
```

## Available options:

### Required options:

* datacenter\_id
* ionoscloud\_username
* ionoscloud\_password

```text
    datacenter_id: --datacenter-id DATACENTER_ID, -D DATACENTER_ID
        iD of the data center (required)

    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username (required)

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password (required)
```
## Example

```text
knife ionoscloud server start SERVER_ID 
```
