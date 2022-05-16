# NodepoolUpdate

Updates information about a Ionoscloud K8s Nodepool.

```text
knife ionoscloud nodepool update (options)
```

## Available options:

### Required options:

* cluster\_id
* nodepool\_id

```text
    ionoscloud_url: --url URL
        the Ionoscloud API URL

    extra_config_file: --extra-config EXTRA_CONFIG_FILE_PATH, -e EXTRA_CONFIG_FILE_PATH
        path to the additional config file

    cluster_id: --cluster-id CLUSTER_ID, -C CLUSTER_ID
        iD of the Kubernetes cluster (required)

    nodepool_id: --nodepool-id NODEPOOL_ID, -P NODEPOOL_ID
        iD of the Kubernetes nodepool (required)

    k8s_version: --version VERSION, -v VERSION
        the version for the Kubernetes cluster.

    maintenance_day: --maintenance-day MAINTENANCE_DAY
        day Of the week when to perform the maintenance.

    maintenance_time: --maintenance-time MAINTENANCE_TIME, -t MAINTENANCE_TIME
        time Of the day when to perform the maintenance.

    node_count: --node-count NODE_COUNT, -c NODE_COUNT
        the number of worker nodes that the node pool should contain. Min 2, Max: Determined by the resource availability.

    min_node_count: --min-node-count MIN_NODE_COUNT
        the minimum number of worker nodes that the managed node group can scale in

    max_node_count: --max-node-count MAX_NODE_COUNT
        the maximum number of worker nodes that the managed node pool can scale-out.

    lans: --lans LAN_ID [LAN_ID]
        an array of additional private LANs attached to worker nodes

    public_ips: --ips PUBLIC_IP [PUBLIC_IP]
        optional array of reserved public IP addresses to be used by the nodes. IPs must be from same location as the data center used for the node pool. The array must contain one extra IP than maximum number of nodes could be. (nodeCount+1 if fixed node amount or maxNodeCount+1 if auto scaling is used) The extra provided IP Will be used during rebuilding of nodes.

    labels: --labels LABEL [LABEL]
        map of labels attached to node pool

    annotations: --annotations ANNOTATION [ANNOTATION]
        map of annotations attached to node pool

    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password

    ionoscloud_token: --token PASSWORD
        your Ionoscloud access token

```
## Example

```text
knife ionoscloud nodepool update --url URL --extra-config EXTRA_CONFIG_FILE_PATH --cluster-id CLUSTER_ID --nodepool-id NODEPOOL_ID --version VERSION --maintenance-day MAINTENANCE_DAY --maintenance-time MAINTENANCE_TIME --node-count NODE_COUNT --min-node-count MIN_NODE_COUNT --max-node-count MAX_NODE_COUNT --lans LAN_ID [LAN_ID] --ips PUBLIC_IP [PUBLIC_IP] --labels LABEL [LABEL] --annotations ANNOTATION [ANNOTATION] --username USERNAME --password PASSWORD --token PASSWORD
```
