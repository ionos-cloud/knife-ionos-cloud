# S3keyDelete

This operation deletes a specific S3 key.

```text
knife ionoscloud s3key delete S3KEY_ID [S3KEY_ID] (options)
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
knife ionoscloud s3key delete S3KEY_ID 
```
