# NodepoolCreate

Creates a node pool into an existing Kubernetes cluster. The Kubernetes cluster must be in state "ACTIVE" before creating a node pool.

The worker nodes within the node pools will be deployed into an existing data centers.

```text
knife ionoscloud nodepool create (options)
```

## Available options:

### Required options:

* datacenter\_id
* cluster\_id
* name
* version
* node\_count
* cpu\_family
* cores
* ram
* availability\_zone
* storage\_type
* storage\_size
* ionoscloud\_username
* ionoscloud\_password

```text
    datacenter_id: --datacenter-id DATACENTER_ID, -D DATACENTER_ID
        iD of the virtual datacenter (required)

    cluster_id: --cluster-id CLUSTER_ID, -C CLUSTER_ID
        iD of the Kubernetes cluster (required)

    name: --name NAME, -n NAME
        name of the Kubernetes node pool (required)

    version: --version VERSION, -v VERSION
        the version for the Kubernetes cluster. (required)

    maintenance_day: --maintenance-day MAINTENANCE_DAY, -d MAINTENANCE_DAY
        day Of the week when to perform the maintenance.

    maintenance_time: --maintenance-time MAINTENANCE_TIME, -t MAINTENANCE_TIME
        time Of the day when to perform the maintenance.

    node_count: --node-count NODE_COUNT, -c NODE_COUNT
        the number of worker nodes that the node pool should contain. Min 2, Max: Determined by the resource availability. (required)

    cpu_family: --cpu-family CPU_FAMILY, -f CPU_FAMILY
        sets the CPU type. [AMD_OPTERON, INTEL_XEON, INTEL_SKYLAKE] (required)

    cores: --cores CORES
        the total number of cores for the node. (required)

    ram: --ram RAM, -r RAM
        the amount of RAM in MB (required)

    availability_zone: --availability-zone AVAILABILITY_ZONE, -a AVAILABILITY_ZONE
        the availability zone of the node pool (required)

    storage_type: --storage-type STORAGE_TYPE
        sets the storage type. [HDD, SSD] (required)

    storage_size: --storage-size STORAGE_SIZE
        the total allocated storage capacity of a node. (required)

    min_node_count: --min-node-count MIN_NODE_COUNT
        the minimum number of worker nodes that the managed node group can scale in

    max_node_count: --max-node-count MAX_NODE_COUNT
        the maximum number of worker nodes that the managed node pool can scale-out.

    lans: --lans LAN_ID [LAN_ID]
        an array of additional private LANs attached to worker nodes

    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username (required)

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password (required)
```
## Example

```text
knife ionoscloud nodepool create --datacenter-id DATACENTER_ID --cluster-id CLUSTER_ID --name NAME --version VERSION --maintenance-day MAINTENANCE_DAY --maintenance-time MAINTENANCE_TIME --node-count NODE_COUNT --cpu-family CPU_FAMILY --cores CORES --ram RAM --availability-zone AVAILABILITY_ZONE --storage-type STORAGE_TYPE --storage-size STORAGE_SIZE --min-node-count MIN_NODE_COUNT --max-node-count MAX_NODE_COUNT --lans LAN_ID [LAN_ID] --username USERNAME --password PASSWORD
```
<<<<<<< HEAD
=======

>>>>>>> parent of 32dffce... changes for 5.1.0
