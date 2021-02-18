# DatacenterDelete

You will want to exercise a bit of caution here. Removing a data center will destroy all objects contained within that data center -- servers, volumes, snapshots, and so on. The objects -- once removed -- will be unrecoverable.

    knife ionoscloud datacenter delete DATACENTER_ID [DATACENTER_ID]


## Available options:
---

### Required options:

```
    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password

```

## Example

    knife ionoscloud datacenter delete DATACENTER_ID [DATACENTER_ID]--username USERNAME --password PASSWORD