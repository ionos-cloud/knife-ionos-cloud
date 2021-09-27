# GroupUpdate

Updates information about a Ionoscloud Group.

```text
knife ionoscloud group update (options)
```

## Available options:

### Required options:

* group\_id
* ionoscloud\_username
* ionoscloud\_password

```text
    group_id: --group-id GROUP_ID, -G GROUP_ID
        iD of the group. (required)

    name: --name NAME, -N NAME
        mame of the group.

    create_data_center: --create-datacenter CREATE_DATACENTER, -D CREATE_DATACENTER
        the group will be allowed to create virtual data centers.

    create_snapshot: --create-snapshot CREATE_SNAPSHOT, -s CREATE_SNAPSHOT
        the group will be allowed to create snapshots.

    reserve_ip: --reserve-ip RESERVE_IP, -i RESERVE_IP
        the group will be allowed to reserve IP addresses.

    access_activity_log: --access-log ACCESS_ACTIVITY_LOG, -a ACCESS_ACTIVITY_LOG
        the group will be allowed to access the activity log.

    s3_privilege: --s3 S3_PRIVILEGE
        the group will be allowed to manage S3

    create_backup_unit: --create-backupunit CREATE_BACKUPUNIT, -b CREATE_BACKUPUNIT
        the group will be able to manage backup units.

    create_k8s_cluster: --create-k8s-cluster CREATE_K8S_CLUSTER
        the group will be able to create kubernetes clusters.

    create_pcc: --create-pcc CREATE_PCC
        the group will be able to manage pccs.

    create_internet_access: --create-internet-access CREATE_INTERNET_ACCESS
        the group will be have internet access privilege.

    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username (required)

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password (required)

    extra_config_file: --extra-config EXTRA_CONFIG_FILE_PATH, -e EXTRA_CONFIG_FILE_PATH
        path to the additional config file

```
## Example

```text
knife ionoscloud group update --group-id GROUP_ID --name NAME --create-datacenter CREATE_DATACENTER --create-snapshot CREATE_SNAPSHOT --reserve-ip RESERVE_IP --access-log ACCESS_ACTIVITY_LOG --s3 S3_PRIVILEGE --create-backupunit CREATE_BACKUPUNIT --create-k8s-cluster CREATE_K8S_CLUSTER --create-pcc CREATE_PCC --create-internet-access CREATE_INTERNET_ACCESS --username USERNAME --password PASSWORD --extra-config EXTRA_CONFIG_FILE_PATH
```