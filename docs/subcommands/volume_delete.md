# VolumeDelete

Deletes the specified volume. This will result in the volume being removed from your virtual data center. Please use this with caution!

    knife ionoscloud volume delete SERVER_ID [SERVER_ID] (options)


## Available options:
---

### Required options:
* datacenter_id

```
    datacenter_id: --datacenter-id ID, -D ID
        name of the data center (required)

    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password

```

## Example

    knife ionoscloud volume delete SERVER_ID 
