# GroupGet

Retrieves detailed information about a specific group. This will also retrieve a list of users who are members of the group.

```text
knife ionoscloud group get (options)
```

## Available options:

### Required options:

* group\_id

```text
    ionoscloud_url: --url URL
        the Ionoscloud API URL

    extra_config_file: --extra-config EXTRA_CONFIG_FILE_PATH, -e EXTRA_CONFIG_FILE_PATH
        path to the additional config file

    group_id: --group-id GROUP_ID, -G GROUP_ID
        iD of the group. (required)

    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password

    ionoscloud_token: --token PASSWORD
        your Ionoscloud access token

```
## Example

```text
knife ionoscloud group get --url URL --extra-config EXTRA_CONFIG_FILE_PATH --group-id GROUP_ID --username USERNAME --password PASSWORD --token PASSWORD
```
