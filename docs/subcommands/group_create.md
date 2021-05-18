# GroupCreate

Use this operation to create a new group and set group privileges.

```text
knife ionoscloud group create (options)
```

## Available options:

### Required options:

* name
* ionoscloud\_username
* ionoscloud\_password

```text
    name: --name NAME, -N NAME
        mame of the group. (required)

    create_data_center: --create-datacenter, -D
        the group will be allowed to create virtual data centers.

    create_snapshot: --create-snapshot, -s
        the group will be allowed to create snapshots.

    reserve_ip: --reserve-ip, -i
        the group will be allowed to reserve IP addresses.

    access_activity_log: --access-log, -a
        the group will be allowed to access the activity log.

    s3_privilege: --s3
        the group will be allowed to manage S3

    create_backup_unit: --create-backupunit, -b
        the group will be able to manage backup units.

    create_k8s_cluster: --create-k8s-cluster
        the group will be able to create kubernetes clusters.

    create_pcc: --create-pcc
        the group will be able to manage pccs.

    create_internet_access: --create-internet-access
        the group will be have internet access privilege.

    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username (required)

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password (required)
```
## Example

```text
<<<<<<< HEAD
knife ionoscloud group create --name NAME --create-datacenter --create-snapshot --reserve-ip --access-log --s3 --create-backupunit --create-k8s-cluster --create-pcc --create-internet-access --username USERNAME --password PASSWORD
```
=======
knife ionoscloud group create --name NAME --create-datacenter --create-snapshot --reserve-ip --access-log --s3 --create-backupunit --username USERNAME --password PASSWORD
```

>>>>>>> parent of 32dffce... changes for 5.1.0
