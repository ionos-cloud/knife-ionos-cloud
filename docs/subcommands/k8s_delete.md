# K8sDelete

Deletes a Kubernetes cluster. The cluster cannot contain any node pools when deleting.

```text
knife ionoscloud k8s delete CLUSTER_ID [CLUSTER_ID]
```

## Available options:

### Required options:

* ionoscloud_username
* ionoscloud_password

```text
    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username (required)
    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password (required)
```

## Example

```text
knife ionoscloud k8s delete CLUSTER_ID [CLUSTER_ID]--username USERNAME --password PASSWORD
```
