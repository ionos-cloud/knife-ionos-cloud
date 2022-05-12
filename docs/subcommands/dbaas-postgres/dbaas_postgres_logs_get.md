# DbaasPostgresLogsGet

Retrieves PostgreSQL logs based on the given parameters.

```text
knife ionoscloud dbaas postgres logs get
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
        iD of the cluster (required)

    limit: --limit LIMIT, -l LIMIT
        the maximal number of log lines to return.

    start: --start START
        the start time for the query in RFC3339 format. If both start and since are set, start will be used.

    since: --since SINCE
        the start time for the query using a time delta since the current moment: 2h - 2 hours ago, 20m - 20 minutes ago. Only hours and minutes ar supported, and not at the same time. If both start and since are set, start will be used.

    end: --end END
        the end time for the query in RFC3339 format. If both end and until are set, end will be used.

    until: --until UNTIL
        the end time for the query using a time delta since the current moment: 2h - 2 hours ago, 20m - 20 minutes ago. Only hours and minutes ar supported, and not at the same time. If both end and until are set, end will be used.

    direction: --direction DIRECTION
        the direction in which to scan through the logs. The logs are returned in order of the direction. One of ["BACKWARD", "FORWARD"]

    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password

    ionoscloud_token: --token PASSWORD
        your Ionoscloud access token

```
## Example

```text
knife ionoscloud dbaas postgres logs get--url URL --extra-config EXTRA_CONFIG_FILE_PATH --cluster-id CLUSTER_ID --limit LIMIT --start START --since SINCE --end END --until UNTIL --direction DIRECTION --username USERNAME --password PASSWORD --token PASSWORD
```
