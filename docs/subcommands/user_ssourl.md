# UserSsourl

Retrieve S3 object storage single signon URL for the given user.

```text
knife ionoscloud user ssourl (options)
```

## Available options:

### Required options:

* user\_id
* ionoscloud\_username
* ionoscloud\_password

```text
    user_id: --user-id USER_ID, -U USER_ID
        the ID of the Backup unit. (required)

    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username (required)

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password (required)

    extra_config_file: --extra-config EXTRA_CONFIG_FILE, -e EXTRA_CONFIG_FILE
        additional config file name

```
## Example

```text
knife ionoscloud user ssourl --user-id USER_ID --username USERNAME --password PASSWORD --extra-config EXTRA_CONFIG_FILE
```
