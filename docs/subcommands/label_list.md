# LabelList

List all Labels available to the user. Specify the type and required resource ID to list labels for a specific resource instead.

```text
knife ionoscloud label list (options)
```

## Available options:

### Required options:

* ionoscloud\_username
* ionoscloud\_password

```text
    type: --resource-type RESOURCE_TYPE, -T RESOURCE_TYPE
        type of the resource to be labeled.

    datacenter_id: --datacenter-id DATACENTER_ID, -D DATACENTER_ID
        iD of the data center.

    resource_id: --resource-id RESOURCE_ID, -R RESOURCE_ID
        iD of the resource.

    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username (required)

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password (required)
```
## Example

```text
knife ionoscloud label list --resource-type RESOURCE_TYPE --datacenter-id DATACENTER_ID --resource-id RESOURCE_ID --username USERNAME --password PASSWORD
```
