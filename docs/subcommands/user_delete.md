# UserDelete

Blacklists the user, disabling them. The user is not completely purged, therefore if you anticipate needing to create a user with the same name in the future, we suggest renaming the user before you delete it.

    knife ionoscloud user delete USER_ID [USER_ID]


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

    knife ionoscloud user delete USER_ID [USER_ID]--username USERNAME --password PASSWORD