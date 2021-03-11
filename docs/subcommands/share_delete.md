# ShareDelete

Removes a resource share from a specified group.

    knife ionoscloud server delete SHARE_ID [SHARE_ID] (options)


## Available options:
---

### Required options:
* group_id
* ionoscloud_username
* ionoscloud_password

```
    group_id: --group-id GROUP_ID, -G GROUP_ID
        iD of the group. (required)

    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username (required)

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password (required)

```

## Example

    knife ionoscloud server delete SHARE_ID 
