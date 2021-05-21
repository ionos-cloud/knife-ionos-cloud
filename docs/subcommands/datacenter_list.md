# DatacenterList

Ionoscloud introduces the concept of virtual data centers. These are logically separated from one another and allow you to have a self-contained environment for all servers, volumes, networking, and other resources. The goal is to give you the same experience as you would have if you were running your own physical data center. A list of available data centers can be obtained with the following command.

```text
knife ionoscloud datacenter list
```

## Available options:

### Required options:

* ionoscloud\_username
* ionoscloud\_password

```text
    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username (required)

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password (required)

```
## Example

```text
knife ionoscloud datacenter list--username USERNAME --password PASSWORD
```
