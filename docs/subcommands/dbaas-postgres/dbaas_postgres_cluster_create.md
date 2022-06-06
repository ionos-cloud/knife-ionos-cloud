# DbaasPostgresClusterCreate

Creates a new PostgreSQL cluster. If the `fromBackup` field is populated, the new cluster will be created based on the given backup.

```text
knife ionoscloud dbaas postgres cluster create (options)
```

## Available options:

### Required options:

* postgres\_version
* instances
* cores
* ram
* storage\_size
* storage\_type
* connections
* location
* display\_name
* synchronization\_mode
* username
* password

```text
    ionoscloud_url: --url URL
        the Ionoscloud API URL

    extra_config_file: --extra-config EXTRA_CONFIG_FILE_PATH, -e EXTRA_CONFIG_FILE_PATH
        path to the additional config file

    postgres_version: --postgres-version POSTGRES_VERSION
        the PostgreSQL version of your cluster (required)

    instances: --instances INSTANCES, -R INSTANCES
        the total number of instances in the cluster (one master and n-1 standbys). (required)

    cores: --cores CORES, -C CORES
        the number of CPU cores per instance. (required)

    ram: --ram RAM, -r RAM
        the amount of memory per instance(should be a multiple of 1024). (required)

    storage_size: --size STORAGE_SIZE
        the amount of storage per instance. (required)

    storage_type: --type STORAGE_TYPE
        the storage type used in your cluster. (required)

    connections: --connections CONNECTIONS
        array of VDCs to connect to your cluster. (required)

    location: --location LOCATION, -l LOCATION
        the physical location where the cluster will be created. This will
                            be where all of your instances live. Property cannot be modified
                            after datacenter creation (disallowed in update requests) (required)

    backup_location: --backup-location BACKUP_LOCATION
        the S3 location where the backups will be stored.

    display_name: --name DISPLAY_NAME, -n DISPLAY_NAME
        the friendly name of your cluster. (required)

    from_backup: --from-backup FROM_BACKUP, -b FROM_BACKUP
        deprecated: backup is always enabled. Enables automatic backups of your cluster.

    time: --time TIME
        time Of the day when to perform the maintenance.

    day_of_the_week: --day-of-the-week DAY_OF_THE_WEEK, -d DAY_OF_THE_WEEK
        day Of the week when to perform the maintenance.

    synchronization_mode: --synchronization-mode SYNCHRONIZATION_MODE, -s SYNCHRONIZATION_MODE
        represents different modes of replication. One of [ASYNCHRONOUS, SYNCHRONOUS, STRICTLY_SYNCHRONOUS] (required)

    username: --db-user DB_USERNAME
        the username for the initial postgres user.
                            Some system usernames are restricted (e.g. "postgres", "admin", "standby") (required)

    password: --db-password DB_PASSWORD
        the username for the initial postgres user. (required)

    backup_id: --backup-id BACKUP_ID, -B BACKUP_ID
        iD of backup

    recovery_target_time: --recovery-target-time RECOVERY_TARGET_TIME, -T RECOVERY_TARGET_TIME
        recovery target time

    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password

    ionoscloud_token: --token PASSWORD
        your Ionoscloud access token

```
## Example

```text
knife ionoscloud dbaas postgres cluster create --url URL --extra-config EXTRA_CONFIG_FILE_PATH --postgres-version POSTGRES_VERSION --instances INSTANCES --cores CORES --ram RAM --size STORAGE_SIZE --type STORAGE_TYPE --connections CONNECTIONS --location LOCATION --backup-location BACKUP_LOCATION --name DISPLAY_NAME --from-backup FROM_BACKUP --time TIME --day-of-the-week DAY_OF_THE_WEEK --synchronization-mode SYNCHRONIZATION_MODE --db-user DB_USERNAME --db-password DB_PASSWORD --backup-id BACKUP_ID --recovery-target-time RECOVERY_TARGET_TIME --username USERNAME --password PASSWORD --token PASSWORD
```
