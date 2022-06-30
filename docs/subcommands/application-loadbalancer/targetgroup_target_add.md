# TargetgroupTargetAdd

Adds a Target to a Target Group.

```text
knife ionoscloud targetgroup target add (options)
```

## Available options:

### Required options:

* target\_group\_id
* ip
* port
* weight
* ionoscloud\_username
* ionoscloud\_password

```text
    ionoscloud_url: --url URL
        the Ionoscloud API URL

    extra_config_file: --extra-config EXTRA_CONFIG_FILE_PATH, -e EXTRA_CONFIG_FILE_PATH
        path to the additional config file

    target_group_id: --target-group-id TARGET_GROUP_ID, -T TARGET_GROUP_ID
        iD of the Target Group (required)

    ip: --ip IP
        iP of a balanced target VM (required)

    port: --port PORT, -p PORT
        port of the balanced target service. (range: 1 to 65535) (required)

    weight: --weight WEIGHT, -w WEIGHT
        weight parameter is used to adjust the target VM's weight relative to other target VMs. All target VMs will receive a load proportional to their weight relative to the sum of all weights, so the higher the weight, the higher the load. The default weight is 1, and the maximal value is 256. A value of 0 means the target VM will not participate in load-balancing but will still accept persistent connections. If this parameter is used to distribute the load according to target VM's capacity, it is recommended to start with values which can both grow and shrink, for instance between 10 and 100 to leave enough room above and below for later adjustments. (required)

    health_check_disable: --health-check-disable
        enabling the health check makes the target available only if it accepts periodic health check TCP connection attempts; when turned off, the target is considered always available. The health check only consists of a connection attempt to the address and port of the target. Default is having the health check enabled.

    maintenance_enabled: --maintenance
        maintenance mode prevents the target from receiving balanced traffic.

    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username (required)

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password (required)

    ionoscloud_token: --token PASSWORD
        your Ionoscloud access token

```
## Example

```text
knife ionoscloud targetgroup target add --url URL --extra-config EXTRA_CONFIG_FILE_PATH --target-group-id TARGET_GROUP_ID --ip IP --port PORT --weight WEIGHT --health-check-disable --maintenance --username USERNAME --password PASSWORD --token PASSWORD
```
