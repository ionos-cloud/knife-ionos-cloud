# NodepoolDelete

Deletes a node pool within an existing Kubernetes cluster.

```text
knife ionoscloud nodepool delete NODEPOOL_ID [NODEPOOL_ID] (options)
```

## Available options:

### Required options:

* cluster\_id
* ionoscloud\_username
* ionoscloud\_password

```text
    cluster_id: --cluster-id CLUSTER_ID, -C CLUSTER_ID
        the ID of the K8s Cluster (required)

    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username (required)

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password (required)

```
## Example

```text
knife ionoscloud nodepool delete NODEPOOL_ID 
```
