# K8sCreate

Creates a new Managed Kubernetes cluster.

```text
knife ionoscloud k8s create (options)
```

## Available options:

### Required options:

* name
* ionoscloud\_username
* ionoscloud\_password

```text
    name: --name NAME, -n NAME
        name of the server (required)

    version: --version VERSION, -v VERSION
        the version for the Kubernetes cluster.

    private: --private
        the indicator if the cluster is public or private. Be aware that setting it to false is currently in beta phase.

    gateway_ip: --gateway GATEWAY_IP
        the IP address of the gateway used by the cluster. This is mandatory when `public` is set to `false` and should not be provided otherwise.

    maintenance_day: --maintenance-day MAINTENANCE_DAY, -d MAINTENANCE_DAY
        day Of the week when to perform the maintenance.

    maintenance_time: --maintenance-time MAINTENANCE_TIME, -t MAINTENANCE_TIME
        time Of the day when to perform the maintenance.

    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username (required)

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password (required)

    extra_config_file: --extra-config EXTRA_CONFIG_FILE_PATH, -e EXTRA_CONFIG_FILE_PATH
        path to the additional config file

```
## Example

```text
knife ionoscloud k8s create --name NAME --version VERSION --private --gateway GATEWAY_IP --maintenance-day MAINTENANCE_DAY --maintenance-time MAINTENANCE_TIME --username USERNAME --password PASSWORD --extra-config EXTRA_CONFIG_FILE_PATH
```
