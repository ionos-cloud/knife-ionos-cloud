# S3keyDelete

This operation deletes a specific S3 key.

    knife ionoscloud s3key delete S3KEY_ID [S3KEY_ID]


## Available options:
---

### Required options:
* user
* ionoscloud_username
* ionoscloud_password

```
    user: --user USER_ID, -u USER_ID
        the ID of the user (required)

    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username (required)

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password (required)

```

## Example

    knife ionoscloud s3key delete S3KEY_ID [S3KEY_ID]--user USER_ID --username USERNAME --password PASSWORD
