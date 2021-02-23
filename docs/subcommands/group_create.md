# GroupCreate

Use this operation to create a new group and set group privileges.

    knife ionoscloud group create (options)


## Available options:
---

### Required options:
* name
* ionoscloud_username
* ionoscloud_password

```
    name: --name NAME, -N NAME
        mame of the group. (required)

    create_datacenter: --create-datacenter, -D
        the group will be allowed to create virtual data centers.

    create_snapshot: --create-snapshot, -s
        the group will be allowed to create snapshots.

    reserve_ip: --reserve-ip, -i
        the group will be allowed to reserve IP addresses.

    access_activity_log: --access-log, -a
        the group will be allowed to access the activity log.

    s3_privilege: --s3
        the group will be allowed to manage S3

    create_backupunit: --create-backupunit, -b
        the group will be able to manage backup units.

    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username (required)

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password (required)

```

## Example

    knife ionoscloud group create --name NAME --create-datacenter --create-snapshot --reserve-ip --access-log --s3 --create-backupunit --username USERNAME --password PASSWORD
