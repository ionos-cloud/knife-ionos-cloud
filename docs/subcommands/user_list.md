# UserList

Retrieve a list of all the users that have been created under a contract. You can retrieve a list of users who are members of the group by passing the _group\_id_ option.

```text
knife ionoscloud user list (options)
```

## Available options:

### Required options:

* ionoscloud\_username
* ionoscloud\_password

```text
    group_id: --group-id GROUP_ID, -g GROUP_ID
        iD of the group.

    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username (required)

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password (required)

    extra_config_file: --extra-config EXTRA_CONFIG_FILE_PATH, -e EXTRA_CONFIG_FILE_PATH
        path to the additional config file
```

## Example

```text
knife ionoscloud user list --group-id GROUP_ID --username USERNAME --password PASSWORD --extra-config EXTRA_CONFIG_FILE_PATH
```

