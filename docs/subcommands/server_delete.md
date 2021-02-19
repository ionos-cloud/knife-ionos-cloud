# ServerDelete

This will remove a server from a VDC.

**NOTE**: This will not automatically remove the storage volume(s) attached to a server. A separate API call is required to perform that action.

    knife ionoscloud server delete SERVER_ID [SERVER_ID] (options)


## Available options:
---

### Required options:
* datacenter_id
* ionoscloud_username
* ionoscloud_password

```
    datacenter_id: --datacenter-id DATACENTER_ID, -D DATACENTER_ID
        name of the data center (required)

    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username (required)

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password (required)

```

## Example

    knife ionoscloud server delete SERVER_ID 
