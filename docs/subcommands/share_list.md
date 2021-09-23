# ShareList

Retrieves a full list of all the resources that are shared through this group and lists the permissions granted to the group members for each shared resource.

```text
knife ionoscloud share list (options)
```

## Available options:

### Required options:

* group\_id
* ionoscloud\_username
* ionoscloud\_password

```text
    group_id: --group-id GROUP_ID, -G GROUP_ID
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
knife ionoscloud share list --group-id GROUP_ID --username USERNAME --password PASSWORD --extra-config EXTRA_CONFIG_FILE_PATH
```

