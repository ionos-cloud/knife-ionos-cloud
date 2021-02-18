# S3keyCreate

Creates a new S3 key for a particular user.

    knife ionoscloud s3key create (options)


## Available options:
---

### Required options:
* user

```
    user: --user USER_ID, -u USER_ID
        the ID of the user (required)

    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password

```

## Example

    knife ionoscloud s3key create --user USER_ID --username USERNAME --password PASSWORD
