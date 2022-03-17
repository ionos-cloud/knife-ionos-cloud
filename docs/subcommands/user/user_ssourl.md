# UserSsourl

Retrieve S3 object storage single signon URL for the given user.

```text
knife ionoscloud user ssourl (options)
```

## Available options:

### Required options:

* user\_id

```text
    ionoscloud_url: --url URL
        the Ionoscloud API URL

    extra_config_file: --extra-config EXTRA_CONFIG_FILE_PATH, -e EXTRA_CONFIG_FILE_PATH
        path to the additional config file

    user_id: --user-id USER_ID, -U USER_ID
        the ID of the Backup unit. (required)

    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password

    ionoscloud_token: --token PASSWORD
        your Ionoscloud access token

```
## Example

```text
knife ionoscloud user ssourl --url URL --extra-config EXTRA_CONFIG_FILE_PATH --user-id USER_ID --username USERNAME --password PASSWORD --token PASSWORD
```
