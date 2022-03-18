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
    extra_config_file: --extra-config EXTRA_CONFIG_FILE_PATH, -e EXTRA_CONFIG_FILE_PATH
        path to the additional config file

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

    create_flow_log: --create-flow-log CREATE_FLOW_LOG
        the group will be granted create Flow Logs privilege.

    access_and_manage_monitoring: --manage-monitoring ACCESS_AND_MANAGE_MONITORING
        privilege for a group to access and manage monitoring related functionality (access metrics, CRUD on alarms, alarm-actions etc) using Monotoring-as-a-Service (MaaS).

    access_and_manage_certificates: --manage-certificates ACCESS_AND_MANAGE_CERTIFICATES
        privilege for a group to access and manage certificates.

    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username (required)

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password (required)

    ionoscloud_url: --url URL
        the Ionoscloud API URL

```
## Example

```text
knife ionoscloud group update --extra-config EXTRA_CONFIG_FILE_PATH --group-id GROUP_ID --name NAME --create-datacenter CREATE_DATACENTER --create-snapshot CREATE_SNAPSHOT --reserve-ip RESERVE_IP --access-log ACCESS_ACTIVITY_LOG --s3 S3_PRIVILEGE --create-backupunit CREATE_BACKUPUNIT --create-k8s-cluster CREATE_K8S_CLUSTER --create-pcc CREATE_PCC --create-internet-access CREATE_INTERNET_ACCESS --create-flow-log CREATE_FLOW_LOG --manage-monitoring ACCESS_AND_MANAGE_MONITORING --manage-certificates ACCESS_AND_MANAGE_CERTIFICATES --username USERNAME --password PASSWORD --url URL
```
