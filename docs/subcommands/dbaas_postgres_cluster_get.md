# DbaasPostgresClusterGet

Retrieves information about a Ionoscloud DBaaS Cluster.

```text
knife ionoscloud dbaas postgres cluster get (options)
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

    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username (required)

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password (required)

    ionoscloud_url: --url URL
        the Ionoscloud API URL

```
## Example

```text
knife ionoscloud dbaas postgres cluster get --extra-config EXTRA_CONFIG_FILE_PATH --cluster-id CLUSTER_ID --username USERNAME --password PASSWORD --url URL
```