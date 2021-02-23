# UserList

Retrieve a list of all the users that have been created under a contract. You can retrieve a list of users who are members of the group by passing the *group_id* option.

    knife ionoscloud user list (options)


## Available options:
---

### Required options:
* ionoscloud_username
* ionoscloud_password

```
    group_id: --group-id GROUP_ID, -g GROUP_ID
        iD of the group.

    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username (required)

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password (required)

```

## Example

    knife ionoscloud user list --group-id GROUP_ID --username USERNAME --password PASSWORD
