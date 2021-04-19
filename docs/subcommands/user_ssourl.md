# UserSsourl

Retrieve S3 object storage single signon URL for the given user.

```text
knife ionoscloud user ssourl (options)
```

## Available options:

### Required options:

* user_id
* ionoscloud_username
* ionoscloud_password

```text
    user_id: --user-id USER_ID, -U USER_ID
        the ID of the Backup unit. (required)
    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username (required)
    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password (required)
```

## Example

```text
knife ionoscloud user ssourl --user-id USER_ID --username USERNAME --password PASSWORD
```
