# UserList

Retrieve a list of all the users that have been created under a contract. You can retrieve a list of users who are members of the group by passing the _group\_id_ option.

```text
knife ionoscloud user list (options)
```

## Available options:

### Required options:


```text
    ionoscloud_url: --url URL
        the Ionoscloud API URL

    extra_config_file: --extra-config EXTRA_CONFIG_FILE_PATH, -e EXTRA_CONFIG_FILE_PATH
        path to the additional config file

    group_id: --group-id GROUP_ID, -g GROUP_ID
        iD of the group.

    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password

    ionoscloud_token: --token PASSWORD
        your Ionoscloud access token

```
## Example

```text
knife ionoscloud user list --url URL --extra-config EXTRA_CONFIG_FILE_PATH --group-id GROUP_ID --username USERNAME --password PASSWORD --token PASSWORD
```
