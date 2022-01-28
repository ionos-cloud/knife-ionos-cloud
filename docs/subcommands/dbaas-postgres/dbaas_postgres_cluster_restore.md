# DbaasPostgresClusterRestore

Triggers an in-place restore of the given PostgreSQL.

```text
knife ionoscloud dbaas postgres cluster restore (options)
```

## Available options:

### Required options:

* cluster\_id
* ionoscloud\_username
* ionoscloud\_password

```text
    extra_config_file: --extra-config EXTRA_CONFIG_FILE_PATH, -e EXTRA_CONFIG_FILE_PATH
        path to the additional config file

    cluster_id: --cluster-id CLUSTER_ID, -C CLUSTER_ID
        iD of the cluster (required)

    backup_id: --backup-id BACKUP_ID, -B BACKUP_ID
        iD of backup

    recovery_target_time: --recovery-target-time RECOVERY_TARGET_TIME, -T RECOVERY_TARGET_TIME
        recovery target time

    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username (required)

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password (required)

    ionoscloud_url: --url URL
        the Ionoscloud API URL

```
## Example

```text
knife ionoscloud dbaas postgres cluster restore --extra-config EXTRA_CONFIG_FILE_PATH --cluster-id CLUSTER_ID --backup-id BACKUP_ID --recovery-target-time RECOVERY_TARGET_TIME --username USERNAME --password PASSWORD --url URL
```
