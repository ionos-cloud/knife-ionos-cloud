# ShareDelete

Removes a resource share from a specified group.

```text
knife ionoscloud server delete SHARE_ID [SHARE_ID] (options)
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
knife ionoscloud server delete SHARE_ID 
```
