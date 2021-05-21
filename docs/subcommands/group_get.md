# GroupGet

Retrieves detailed information about a specific group. This will also retrieve a list of users who are members of the group.

    knife ionoscloud group get (options)


## Available options:
---

### Required options:
* group_id
* ionoscloud_username
* ionoscloud_password

```
    group_id: --group-id GROUP_ID, -G GROUP_ID
        iD of the group. (required)

    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username (required)

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password (required)

```
## Example

```text
knife ionoscloud group get --group-id GROUP_ID --username USERNAME --password PASSWORD
```
