# NodepoolLanRemove

Adds or updates a LAN within a Nodepool.

```text
knife ionoscloud nodepool lan remove LAN_ID [LAN_ID] (options)
```

## Available options:

### Required options:

* cluster\_id
* nodepool\_id
* ionoscloud\_username
* ionoscloud\_password

```text
    cluster_id: --cluster-id CLUSTER_ID, -C CLUSTER_ID
        iD of the Kubernetes cluster (required)

    nodepool_id: --nodepool NODEPOOL_ID, -N NODEPOOL_ID
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
knife ionoscloud nodepool lan remove LAN_ID 
```
