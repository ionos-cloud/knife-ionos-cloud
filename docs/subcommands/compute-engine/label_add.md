# LabelAdd

Add a Label to a Resource.

```text
knife ionoscloud label add (options)
```

## Available options:

### Required options:

* type
* resource\_id
* key
* value

```text
    ionoscloud_url: --url URL
        the Ionoscloud API URL

    extra_config_file: --extra-config EXTRA_CONFIG_FILE_PATH, -e EXTRA_CONFIG_FILE_PATH
        path to the additional config file

    type: --resource-type RESOURCE_TYPE, -T RESOURCE_TYPE
        type of the resource to be labeled. Must be one of [datacenter, server, volume, ipblock, snapshot] (required)

    key: --key KEY, -K KEY
        key of the label. (required)

    value: --value VALUE
        value of the label. (required)

    datacenter_id: --datacenter-id DATACENTER_ID, -D DATACENTER_ID
        iD of the data center.

    resource_id: --resource-id RESOURCE_ID, -R RESOURCE_ID
        iD of the resource. (required)

    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password

    ionoscloud_token: --token PASSWORD
        your Ionoscloud access token

```
## Example

```text
knife ionoscloud label add --url URL --extra-config EXTRA_CONFIG_FILE_PATH --resource-type RESOURCE_TYPE --key KEY --value VALUE --datacenter-id DATACENTER_ID --resource-id RESOURCE_ID --username USERNAME --password PASSWORD --token PASSWORD
```
