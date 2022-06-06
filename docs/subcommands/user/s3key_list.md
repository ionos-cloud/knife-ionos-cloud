# S3keyList

Retrieve a list of all the S3 keys for a specific user.

```text
knife ionoscloud s3key list (options)
```

## Available options:

### Required options:

* user\_id

```text
    ionoscloud_url: --url URL
        the Ionoscloud API URL

    extra_config_file: --extra-config EXTRA_CONFIG_FILE_PATH, -e EXTRA_CONFIG_FILE_PATH
        path to the additional config file

    user_id: --user USER_ID, -u USER_ID
        the ID of the user (required)

    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password

    ionoscloud_token: --token PASSWORD
        your Ionoscloud access token

```
## Example

```text
knife ionoscloud s3key list --url URL --extra-config EXTRA_CONFIG_FILE_PATH --user USER_ID --username USERNAME --password PASSWORD --token PASSWORD
```
