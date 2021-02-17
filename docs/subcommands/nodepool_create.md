# NodepoolCreate



    knife ionoscloud nodepool create (options)


## Available options:

```
* ionoscloud_username: --username USERNAME, -u USERNAME   Your Ionoscloud username
* ionoscloud_password: --password PASSWORD, -p PASSWORD   Your Ionoscloud password
* datacenter_id: --datacenter-id DATACENTER_ID, -D DATACENTER_ID   ID of the virtual datacenter
* cluster_id: --cluster-id CLUSTER_ID, -C CLUSTER_ID   ID of the Kubernetes cluster
* name: --name NAME, -n NAME   Name of the Kubernetes node pool
* version: --version VERSION, -v VERSION   The version for the Kubernetes cluster.
* maintenanceday: --maintenance-day MAINTENANCE_DAY, -d MAINTENANCE_DAY   Day Of the week when to perform the maintenance.
* maintenancetime: --maintenance-time MAINTENANCE_TIME, -t MAINTENANCE_TIME   Time Of the day when to perform the maintenance.
* nodecount: --node-count NODE_COUNT, -c NODE_COUNT   The number of worker nodes that the node pool should contain. Min 2, Max: Determined by the resource availability.
* cpufamily: --cpu-family CPU_FAMILY, -f CPU_FAMILY   Sets the CPU type. [AMD_OPTERON, INTEL_XEON, INTEL_SKYLAKE]
* cores: --cores CORES,    The total number of cores for the node.
* ram: --ram RAM, -r RAM   The amount of RAM in MB
* availabilityzone: --availability-zone AVAILABILITY_ZONE, -a AVAILABILITY_ZONE   The availability zone of the node pool
* storagetype: --storage-type STORAGE_TYPE,    Sets the storage type. [HDD, SSD]
* storagesize: --storage-size STORAGE_SIZE,    The total allocated storage capacity of a node.
* minnodecount: --min-node-count MIN_NODE_COUNT,    The minimum number of worker nodes that the managed node group can scale in
* maxnodecount: --max-node-count MAX_NODE_COUNT,    The maximum number of worker nodes that the managed node pool can scale-out.
* lans: --lans LAN_ID [LAN_ID],    An array of additional private LANs attached to worker nodes
```

## Example

    knife ionoscloud nodepool create --username USERNAME --password PASSWORD --datacenter-id DATACENTER_ID --cluster-id CLUSTER_ID --name NAME --version VERSION --maintenance-day MAINTENANCE_DAY --maintenance-time MAINTENANCE_TIME --node-count NODE_COUNT --cpu-family CPU_FAMILY --cores CORES --ram RAM --availability-zone AVAILABILITY_ZONE --storage-type STORAGE_TYPE --storage-size STORAGE_SIZE --min-node-count MIN_NODE_COUNT --max-node-count MAX_NODE_COUNT --lans LAN_ID [LAN_ID]
