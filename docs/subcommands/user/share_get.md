# ShareGet

Retrieves the attributes of a given Group Share.

```text
knife ionoscloud share get (options)
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

    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password

    ionoscloud_token: --token PASSWORD
        your Ionoscloud access token

```
## Example

```text
knife ionoscloud share get --url URL --extra-config EXTRA_CONFIG_FILE_PATH --group-id GROUP_ID --resource-id RESOURCE_ID --username USERNAME --password PASSWORD --token PASSWORD
```
