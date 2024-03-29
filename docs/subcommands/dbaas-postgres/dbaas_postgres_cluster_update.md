# DbaasPostgresClusterUpdate

Updates information about a Ionoscloud Dbaas Cluster.

```text
knife ionoscloud dbaas postgres cluster update (options)
```

## Available options:

### Required options:

* cluster\_id

```text
    ionoscloud_url: --url URL
        the Ionoscloud API URL

    extra_config_file: --extra-config EXTRA_CONFIG_FILE_PATH, -e EXTRA_CONFIG_FILE_PATH
        path to the additional config file

    cluster_id: --cluster-id CLUSTER_ID, -C CLUSTER_ID
        iD of the cluster (required)

    cores: --cores CORES, -C CORES
        the number of CPU cores per instance.

    ram_size: --ram RAM, -r RAM
        the amount of memory per instance.

    storage_size: --size STORAGE_SIZE
        the amount of storage per instance.

    connections: --connections CONNECTIONS
        array of VDCs to connect to your cluster.

    display_name: --name DISPLAY_NAME, -n DISPLAY_NAME
        the friendly name of your cluster.

    time: --time TIME
        time Of the day when to perform the maintenance.

    day_of_the_week: --day-of-the-week DAY_OF_THE_WEEK, -d DAY_OF_THE_WEEK
        day Of the week when to perform the maintenance.

    postgres_version: --postgres-version POSTGRES_VERSION
        the PostgreSQL version of your cluster

    instances: --instances INSTANCES, -R INSTANCES
        the total number of instances in the cluster (one master and n-1 standbys).

    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password

    ionoscloud_token: --token PASSWORD
        your Ionoscloud access token

```
## Example

```text
knife ionoscloud dbaas postgres cluster update --url URL --extra-config EXTRA_CONFIG_FILE_PATH --cluster-id CLUSTER_ID --cores CORES --ram RAM --size STORAGE_SIZE --connections CONNECTIONS --name DISPLAY_NAME --time TIME --day-of-the-week DAY_OF_THE_WEEK --postgres-version POSTGRES_VERSION --instances INSTANCES --username USERNAME --password PASSWORD --token PASSWORD
```
