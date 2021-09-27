# UserGet

Retrieves the attributes of a given Ionoscloud User.

```text
knife ionoscloud user get (options)
```

## Available options:

### Required options:

* user\_id
* ionoscloud\_username
* ionoscloud\_password

```text
    user_id: --user-id USER_ID, -U USER_ID
        iD of the group. (required)

    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username (required)

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password (required)

    extra_config_file: --extra-config EXTRA_CONFIG_FILE_PATH, -e EXTRA_CONFIG_FILE_PATH
        path to the additional config file

```
## Example

```text
knife ionoscloud user get --user-id USER_ID --username USERNAME --password PASSWORD --extra-config EXTRA_CONFIG_FILE_PATH
```
