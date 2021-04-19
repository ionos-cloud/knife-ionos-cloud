# S3keyDelete

This operation deletes a specific S3 key.

```text
knife ionoscloud s3key delete S3KEY_ID [S3KEY_ID] (options)
```

## Available options:
---

### Required options:

* user_id
* ionoscloud_username
* ionoscloud_password

```text
    user_id: --user USER_ID, -u USER_ID
        the ID of the user (required)

    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username (required)

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password (required)

```

## Example

```text
knife ionoscloud s3key delete S3KEY_ID 
```
