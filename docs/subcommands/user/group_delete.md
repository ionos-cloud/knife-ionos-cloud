# GroupDelete

Use this operation to delete a single group. Resources that are assigned to the group are NOT deleted, but are no longer accessible to the group members unless the member is a Contract Owner, Admin, or Resource Owner.

```text
knife ionoscloud group delete GROUP_ID [GROUP_ID]
```

## Available options:

### Required options:


```text
    ionoscloud_url: --url URL
        the Ionoscloud API URL

    extra_config_file: --extra-config EXTRA_CONFIG_FILE_PATH, -e EXTRA_CONFIG_FILE_PATH
        path to the additional config file

    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password

    ionoscloud_token: --token PASSWORD
        your Ionoscloud access token

```
## Example

```text
knife ionoscloud group delete GROUP_ID [GROUP_ID]--url URL --extra-config EXTRA_CONFIG_FILE_PATH --username USERNAME --password PASSWORD --token PASSWORD
```
