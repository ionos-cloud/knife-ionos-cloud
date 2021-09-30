# NodepoolGet

Retrieves the attributes of a given K8S Nodepool.

```text
knife ionoscloud nodepool get (options)
```

## Available options:

### Required options:

* cluster\_id
* nodepool\_id
* ionoscloud\_username
* ionoscloud\_password

```text
    cluster_id: --cluster-id CLUSTER_ID, -C CLUSTER_ID
        the ID of the K8s Cluster (required)

    nodepool_id: --nodepool-id NODEPOOL_ID, -P NODEPOOL_ID
        the ID of the K8s Nodepool (required)

    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username (required)

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password (required)

    extra_config_file: --extra-config EXTRA_CONFIG_FILE_PATH, -e EXTRA_CONFIG_FILE_PATH
        path to the additional config file

```
## Example

```text
knife ionoscloud nodepool get --cluster-id CLUSTER_ID --nodepool-id NODEPOOL_ID --username USERNAME --password PASSWORD --extra-config EXTRA_CONFIG_FILE_PATH
```