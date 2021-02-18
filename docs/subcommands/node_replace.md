# NodeReplace

You can recreate a single Kubernetes Node.

Managed Kubernetes starts a process which based on the nodepool&#39;s template creates &amp; configures a new node, waits for status &quot;ACTIVE&quot;, and migrates all the pods from the faulty node, deleting it once empty. While this operation occurs, the nodepool will have an extra billable &quot;ACTIVE&quot; node.

    knife ionoscloud node replace NODE_ID [NODE_ID] (options)


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

    knife ionoscloud node replace NODE_ID 