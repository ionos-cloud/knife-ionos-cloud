# GroupList

This retrieves a full list of all groups.

```text
knife ionoscloud group list (options)
```

## Available options:

### Required options:

* ionoscloud\_username
* ionoscloud\_password

```text
    extra_config_file: --extra-config EXTRA_CONFIG_FILE_PATH, -e EXTRA_CONFIG_FILE_PATH
        path to the additional config file

    user_id: --user-id USER_ID, -u USER_ID
        iD of the user.

    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username (required)

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password (required)

    ionoscloud_url: --url URL
        the Ionoscloud API URL

```
## Example

```text
knife ionoscloud group list --extra-config EXTRA_CONFIG_FILE_PATH --user-id USER_ID --username USERNAME --password PASSWORD --url URL
```