# K8sCreate

Creates a new Managed Kubernetes cluster.

```text
knife ionoscloud k8s create (options)
```

## Available options:

### Required options:

* name
* ionoscloud_username
* ionoscloud_password

```text
    name: --name NAME, -n NAME
        name of the server (required)
    version: --version VERSION, -v VERSION
        the version for the Kubernetes cluster.
    maintenance_day: --maintenance-day MAINTENANCE_DAY, -d MAINTENANCE_DAY
        day Of the week when to perform the maintenance.
    maintenance_time: --maintenance-time MAINTENANCE_TIME, -t MAINTENANCE_TIME
        time Of the day when to perform the maintenance.
    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username (required)
    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password (required)
```

## Example

```text
knife ionoscloud k8s create --name NAME --version VERSION --maintenance-day MAINTENANCE_DAY --maintenance-time MAINTENANCE_TIME --username USERNAME --password PASSWORD
```
