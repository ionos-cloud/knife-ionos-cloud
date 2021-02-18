# ServerList

List all available servers under a specified data center.

    knife ionoscloud server list (options)


## Available options:
---

### Required options:
* datacenter_id

```
    datacenter_id: --datacenter-id DATACENTER_ID, -D DATACENTER_ID
        the ID of the datacenter containing the server (required)

    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password

```

## Example

    knife ionoscloud server list --datacenter-id DATACENTER_ID --username USERNAME --password PASSWORD
