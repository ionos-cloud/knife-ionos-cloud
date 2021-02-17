# K8sCreate



    knife ionoscloud k8s create (options)


## Available options:

```
    ionoscloud_username: --username USERNAME, -u USERNAME
        Your Ionoscloud username

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        Your Ionoscloud password

    name: --name NAME, -n NAME
        Name of the server

    version: --version VERSION, -v VERSION
        The version for the Kubernetes cluster.

    maintenanceday: --maintenance-day MAINTENANCE_DAY, -d MAINTENANCE_DAY
        Day Of the week when to perform the maintenance.

    maintenancetime: --maintenance-time MAINTENANCE_TIME, -t MAINTENANCE_TIME
        Time Of the day when to perform the maintenance.

```

## Example

    knife ionoscloud k8s create --username USERNAME --password PASSWORD --name NAME --version VERSION --maintenance-day MAINTENANCE_DAY --maintenance-time MAINTENANCE_TIME
