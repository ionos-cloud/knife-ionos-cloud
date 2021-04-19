# NodepoolList

Retrieve a list of all node pools contained in a selected Kubernetes cluster.

```text
knife ionoscloud nodepool list
```

## Available options:

### Required options:

* cluster_id
* ionoscloud_username
* ionoscloud_password

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
knife ionoscloud nodepool list--cluster-id CLUSTER_ID --username USERNAME --password PASSWORD
```
