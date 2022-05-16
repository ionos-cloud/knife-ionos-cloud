# GroupList

This retrieves a full list of all groups.

```text
knife ionoscloud group list (options)
```

## Available options:

### Required options:


```text
    ionoscloud_url: --url URL
        the Ionoscloud API URL

    extra_config_file: --extra-config EXTRA_CONFIG_FILE_PATH, -e EXTRA_CONFIG_FILE_PATH
        path to the additional config file

    user_id: --user-id USER_ID, -u USER_ID
        iD of the user.

    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password

    ionoscloud_token: --token PASSWORD
        your Ionoscloud access token

```
## Example

```text
knife ionoscloud group list --url URL --extra-config EXTRA_CONFIG_FILE_PATH --user-id USER_ID --username USERNAME --password PASSWORD --token PASSWORD
```
