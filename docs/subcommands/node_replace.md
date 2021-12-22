# NodeReplace

You can recreate a single Kubernetes Node.

Managed Kubernetes starts a process which based on the nodepool's template creates & configures a new node, waits for status "ACTIVE", and migrates all the pods from the faulty node, deleting it once empty. While this operation occurs, the nodepool will have an extra billable "ACTIVE" node.

```text
knife ionoscloud node replace NODE_ID [NODE_ID] (options)
```

## Available options:

### Required options:

* cluster\_id
* nodepool\_id
* ionoscloud\_username
* ionoscloud\_password

```text
    extra_config_file: --extra-config EXTRA_CONFIG_FILE_PATH, -e EXTRA_CONFIG_FILE_PATH
        path to the additional config file

    cluster_id: --cluster-id CLUSTER_ID, -C CLUSTER_ID
        the ID of the K8s Cluster (required)

    nodepool_id: --nodepool-id NODEPOOL_ID, -P NODEPOOL_ID
        the ID of the K8s Nodepool (required)

    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username (required)

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password (required)

    ionoscloud_url: --url URL
        the Ionoscloud API URL

```
## Example

```text
knife ionoscloud node replace NODE_ID 
```
