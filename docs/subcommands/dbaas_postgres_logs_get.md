# DbaasPostgresLogsGet

Get logs of your cluster

```text
knife ionoscloud dbaas postgres logs get
```

## Available options:

### Required options:

* cluster\_id
* ionoscloud\_username
* ionoscloud\_password

```text
    extra_config_file: --extra-config EXTRA_CONFIG_FILE_PATH, -e EXTRA_CONFIG_FILE_PATH
        path to the additional config file

    cluster_id: --cluster-id CLUSTER_ID, -C CLUSTER_ID
        iD of the cluster (required)

    limit: --limit LIMIT, -l LIMIT
        the maximal number of log lines to return.

    start: --start START
        the start time for the query in RFC3339 format.

    end: --end END
        the end time for the query in RFC3339 format.

    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username (required)

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password (required)

    ionoscloud_url: --url URL
        the Ionoscloud API URL

```
## Example

```text
knife ionoscloud dbaas postgres logs get--extra-config EXTRA_CONFIG_FILE_PATH --cluster-id CLUSTER_ID --limit LIMIT --start START --end END --username USERNAME --password PASSWORD --url URL
```