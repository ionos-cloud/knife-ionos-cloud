# NodeList

Retrieve a list of Kubernetes Nodes in a Nodepool.

    knife ionoscloud node list


## Available options:
---

### Required options:
* cluster_id
* nodepool_id

```
    cluster_id: --cluster-id CLUSTER_ID, -C CLUSTER_ID
        the ID of the K8s Cluster (required)

    nodepool_id: --nodepool-id NODEPOOL_ID, -P NODEPOOL_ID
        the ID of the K8s Nodepool (required)

    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password

```

## Example

    knife ionoscloud node list--cluster-id CLUSTER_ID --nodepool-id NODEPOOL_ID --username USERNAME --password PASSWORD
