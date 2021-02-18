# NodepoolDelete

Deletes a node pool within an existing Kubernetes cluster.

    knife ionoscloud nodepool delete NODEPOOL_ID [NODEPOOL_ID] (options)


## Available options:
---

### Required options:
* cluster_id

```
    cluster_id: --cluster-id CLUSTER_ID, -C CLUSTER_ID
        the ID of the K8s Cluster (required)

    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password

```

## Example

    knife ionoscloud nodepool delete NODEPOOL_ID 
