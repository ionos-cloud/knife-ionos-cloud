# ServerStart

This will start a server. If the server&#39;s public IP was deallocated then a new IP will be assigned.

    knife ionoscloud server start SERVER_ID [SERVER_ID] (options)


## Available options:
---

### Required options:
* datacenter_id

```
    datacenter_id: --datacenter-id DATACENTER_ID, -D DATACENTER_ID
        iD of the data center (required)

    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password

```

## Example

    knife ionoscloud server start SERVER_ID 