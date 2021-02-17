# KubeconfigGet

Retrieve the kubeconfig file for a given Kubernetes cluster.

    knife ionoscloud kubeconfig get (options)


## Available options:
---

### Required options:
* cluster_id

```
    cluster_id: --cluster-id CLUSTER_ID, -C CLUSTER_ID
        the ID of the Kubernetes cluster. (required)

    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password

```

## Example

    knife ionoscloud kubeconfig get --cluster-id CLUSTER_ID --username USERNAME --password PASSWORD
