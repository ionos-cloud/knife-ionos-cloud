# S3keyGet

Retrieves the properties of an S3 Key.

```text
knife ionoscloud s3key get (options)
```

## Available options:

### Required options:

* user\_id
* s3\_key\_id

```text
    ionoscloud_url: --url URL
        the Ionoscloud API URL

    extra_config_file: --extra-config EXTRA_CONFIG_FILE_PATH, -e EXTRA_CONFIG_FILE_PATH
        path to the additional config file

    user_id: --user USER_ID, -u USER_ID
        the ID of the user (required)

    s3_key_id: --s3-key S3KEY_ID, -S S3KEY_ID
        the ID of the S3 Key. (required)

    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password

    ionoscloud_token: --token PASSWORD
        your Ionoscloud access token

```
## Example

```text
knife ionoscloud s3key get --url URL --extra-config EXTRA_CONFIG_FILE_PATH --user USER_ID --s3-key S3KEY_ID --username USERNAME --password PASSWORD --token PASSWORD
```
