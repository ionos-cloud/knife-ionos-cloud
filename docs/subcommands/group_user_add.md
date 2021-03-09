# GroupUserAdd

Use this operation to add an existing user to a group.

    knife ionoscloud group user add USER_ID [USER_ID] (options)


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

    knife ionoscloud group user add USER_ID 