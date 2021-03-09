# GroupDelete

Use this operation to delete a single group. Resources that are assigned to the group are NOT deleted, but are no longer accessible to the group members unless the member is a Contract Owner, Admin, or Resource Owner.

    knife ionoscloud group delete GROUP_ID [GROUP_ID]


## Available options:
---

### Required options:
* ionoscloud_username
* ionoscloud_password

```
    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username (required)

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password (required)

```

## Example

    knife ionoscloud group delete GROUP_ID [GROUP_ID]--username USERNAME --password PASSWORD