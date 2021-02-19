# NodepoolCreate

Creates a node pool into an existing Kubernetes cluster. The Kubernetes cluster must be in state &quot;ACTIVE&quot; before creating a node pool.

The worker nodes within the node pools will be deployed into an existing data centers.

    knife ionoscloud nodepool create (options)


## Available options:
---

### Required options:
* datacenter_id
* cluster_id
* name
* version
* nodecount
* cpufamily
* cores
* ram
* availabilityzone
* storagetype
* storagesize
* ionoscloud_username
* ionoscloud_password

```
    datacenter_id: --datacenter-id DATACENTER_ID, -D DATACENTER_ID
        iD of the virtual datacenter (required)

    cluster_id: --cluster-id CLUSTER_ID, -C CLUSTER_ID
        iD of the Kubernetes cluster (required)

    name: --name NAME, -n NAME
        name of the Kubernetes node pool (required)

    version: --version VERSION, -v VERSION
        the version for the Kubernetes cluster. (required)

    maintenanceday: --maintenance-day MAINTENANCE_DAY, -d MAINTENANCE_DAY
        day Of the week when to perform the maintenance.

    maintenancetime: --maintenance-time MAINTENANCE_TIME, -t MAINTENANCE_TIME
        time Of the day when to perform the maintenance.

    nodecount: --node-count NODE_COUNT, -c NODE_COUNT
        the number of worker nodes that the node pool should contain. Min 2, Max: Determined by the resource availability. (required)

    cpufamily: --cpu-family CPU_FAMILY, -f CPU_FAMILY
        sets the CPU type. [AMD_OPTERON, INTEL_XEON, INTEL_SKYLAKE] (required)

    cores: --cores CORES
        the total number of cores for the node. (required)

    ram: --ram RAM, -r RAM
        the amount of RAM in MB (required)

    availabilityzone: --availability-zone AVAILABILITY_ZONE, -a AVAILABILITY_ZONE
        the availability zone of the node pool (required)

    storagetype: --storage-type STORAGE_TYPE
        sets the storage type. [HDD, SSD] (required)

    storagesize: --storage-size STORAGE_SIZE
        the total allocated storage capacity of a node. (required)

    minnodecount: --min-node-count MIN_NODE_COUNT
        the minimum number of worker nodes that the managed node group can scale in

    maxnodecount: --max-node-count MAX_NODE_COUNT
        the maximum number of worker nodes that the managed node pool can scale-out.

    lans: --lans LAN_ID [LAN_ID]
        an array of additional private LANs attached to worker nodes

    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username (required)

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password (required)

```

## Example

    knife ionoscloud nodepool create --datacenter-id DATACENTER_ID --cluster-id CLUSTER_ID --name NAME --version VERSION --maintenance-day MAINTENANCE_DAY --maintenance-time MAINTENANCE_TIME --node-count NODE_COUNT --cpu-family CPU_FAMILY --cores CORES --ram RAM --availability-zone AVAILABILITY_ZONE --storage-type STORAGE_TYPE --storage-size STORAGE_SIZE --min-node-count MIN_NODE_COUNT --max-node-count MAX_NODE_COUNT --lans LAN_ID [LAN_ID] --username USERNAME --password PASSWORD
