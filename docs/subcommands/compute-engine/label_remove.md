# LabelRemove

Remove a Label from a Resource.

```text
knife ionoscloud label remove LABEL_KEY [LABEL_KEY] (options)
```

## Available options:

### Required options:

* type
* resource\_id
* ionoscloud\_username
* ionoscloud\_password

```text
    extra_config_file: --extra-config EXTRA_CONFIG_FILE_PATH, -e EXTRA_CONFIG_FILE_PATH
        path to the additional config file

    type: --resource-type RESOURCE_TYPE, -T RESOURCE_TYPE
        type of the resource to be labeled. (required)

    datacenter_id: --datacenter-id DATACENTER_ID, -D DATACENTER_ID
        iD of the data center.

    resource_id: --resource-id RESOURCE_ID, -R RESOURCE_ID
        iD of the resource. (required)

    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username (required)

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password (required)

    ionoscloud_url: --url URL
        the Ionoscloud API URL

```
## Example

```text
knife ionoscloud label remove LABEL_KEY 
```