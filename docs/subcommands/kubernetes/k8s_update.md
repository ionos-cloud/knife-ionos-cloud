# K8sUpdate

Updates information about a Ionoscloud K8s Cluster.

```text
knife ionoscloud k8s update (options)
```

## Available options:

### Required options:

* cluster\_id

```text
    ionoscloud_url: --url URL
        the Ionoscloud API URL

    extra_config_file: --extra-config EXTRA_CONFIG_FILE_PATH, -e EXTRA_CONFIG_FILE_PATH
        path to the additional config file

    cluster_id: --cluster-id CLUSTER_ID, -C CLUSTER_ID
        iD of the Kubernetes cluster (required)

    name: --name NAME, -n NAME
        name of the server

    version: --version VERSION, -v VERSION
        the version for the Kubernetes cluster.

    maintenance_day: --maintenance-day MAINTENANCE_DAY
        day Of the week when to perform the maintenance.

    maintenance_time: --maintenance-time MAINTENANCE_TIME, -t MAINTENANCE_TIME
        time Of the day when to perform the maintenance.

    api_subnet_allow_list: --subnets SUBNET[,SUBNET,...]
        access to the K8s API server is restricted to these CIDRs. Cluster-internal traffic is not affected by this restriction. If no allowlist is specified, access is not restricted. If an IP without subnet mask is provided, the default value will be used: 32 for IPv4 and 128 for IPv6.

    s3_buckets: --s3-buckets BUCKET[,BUCKET,...]
        list of S3 bucket configured for K8s usage. For now it contains only one S3 bucket used to store K8s API audit logs.

    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password

    ionoscloud_token: --token PASSWORD
        your Ionoscloud access token

```
## Example

```text
knife ionoscloud k8s update --url URL --extra-config EXTRA_CONFIG_FILE_PATH --cluster-id CLUSTER_ID --name NAME --version VERSION --maintenance-day MAINTENANCE_DAY --maintenance-time MAINTENANCE_TIME --subnets SUBNET[,SUBNET,...] --s3-buckets BUCKET[,BUCKET,...] --username USERNAME --password PASSWORD --token PASSWORD
```
