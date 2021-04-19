# S3keyList

Retrieve a list of all the S3 keys for a specific user.

```text
knife ionoscloud s3key list (options)
```

## Available options:

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
knife ionoscloud s3key list --user USER_ID --username USERNAME --password PASSWORD
```
