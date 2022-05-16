# GroupCreate

Use this operation to create a new group and set group privileges.

```text
knife ionoscloud group create (options)
```

## Available options:

### Required options:

* name

```text
    ionoscloud_url: --url URL
        the Ionoscloud API URL

    extra_config_file: --extra-config EXTRA_CONFIG_FILE_PATH, -e EXTRA_CONFIG_FILE_PATH
        path to the additional config file

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

    create_flow_log: --create-flow-log
        the group will be granted create Flow Logs privilege.

    access_and_manage_monitoring: --manage-monitoring
        privilege for a group to access and manage monitoring related functionality (access metrics, CRUD on alarms, alarm-actions etc) using Monotoring-as-a-Service (MaaS).

    access_and_manage_certificates: --manage-certificates
        privilege for a group to access and manage certificates.

    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password

    ionoscloud_token: --token PASSWORD
        your Ionoscloud access token

```
## Example

```text
knife ionoscloud group create --url URL --extra-config EXTRA_CONFIG_FILE_PATH --name NAME --create-datacenter --create-snapshot --reserve-ip --access-log --s3 --create-backupunit --create-k8s-cluster --create-pcc --create-internet-access --create-flow-log --manage-monitoring --manage-certificates --username USERNAME --password PASSWORD --token PASSWORD
```
