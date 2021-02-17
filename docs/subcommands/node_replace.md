# NodeReplace



    knife ionoscloud node replace NODE_ID [NODE_ID] (options)


## Available options:

```
* ionoscloud_username: --username USERNAME, -u USERNAME   Your Ionoscloud username
* ionoscloud_password: --password PASSWORD, -p PASSWORD   Your Ionoscloud password
* cluster_id: --cluster-id CLUSTER_ID, -C CLUSTER_ID   The ID of the K8s Cluster
* nodepool_id: --nodepool-id NODEPOOL_ID, -P NODEPOOL_ID   The ID of the K8s Nodepool
```

## Example

    knife ionoscloud node replace NODE_ID [NODE_ID] --username USERNAME --password PASSWORD --cluster-id CLUSTER_ID --nodepool-id NODEPOOL_ID
