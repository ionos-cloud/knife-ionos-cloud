# ShareCreate

Adds a specific resource share to a group and optionally allows the setting of permissions for that resource. As an example, you might use this to grant permissions to use an image or snapshot to a specific group.

```text
knife ionoscloud share create (options)
```

## Available options:

### Required options:

* group\_id
* resource\_id
* ionoscloud\_username
* ionoscloud\_password

```text
    group_id: --group-id GROUP_ID, -G GROUP_ID
        iD of the group. (required)

    resource_id: --resource-id RESOURCE_ID, -R RESOURCE_ID
        the ID of the resource. (required)

    edit_privilege: --edit, -e
        the group has permission to edit privileges on this resource.

    share_privilege: --share, -s
        the group has permission to share this resource.

    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username (required)

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password (required)
```

## Example

```text
knife ionoscloud share create --group-id GROUP_ID --resource-id RESOURCE_ID --edit --share --username USERNAME --password PASSWORD
```

