# ShareUpdate

Updates information about a Ionoscloud Group Share.

```text
knife ionoscloud share update (options)
```

## Available options:

### Required options:

* group\_id
* resource\_id

```text
    ionoscloud_url: --url URL
        the Ionoscloud API URL

    extra_config_file: --extra-config EXTRA_CONFIG_FILE_PATH, -e EXTRA_CONFIG_FILE_PATH
        path to the additional config file

    group_id: --group-id GROUP_ID, -G GROUP_ID
        iD of the group. (required)

    resource_id: --resource-id RESOURCE_ID, -R RESOURCE_ID
        the ID of the resource. (required)

    edit_privilege: --edit EDIT_PRIVILEGE
        the group has permission to edit privileges on this resource.

    share_privilege: --share SHARE_PRIVILEGE, -s SHARE_PRIVILEGE
        the group has permission to share this resource.

    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password

    ionoscloud_token: --token PASSWORD
        your Ionoscloud access token

```
## Example

```text
knife ionoscloud share update --url URL --extra-config EXTRA_CONFIG_FILE_PATH --group-id GROUP_ID --resource-id RESOURCE_ID --edit EDIT_PRIVILEGE --share SHARE_PRIVILEGE --username USERNAME --password PASSWORD --token PASSWORD
```
