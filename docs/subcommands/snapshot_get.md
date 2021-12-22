# SnapshotGet

Retrieves the attributes of a given Snapshot.

```text
knife ionoscloud snapshot get (options)
```

## Available options:

### Required options:

* snapshot\_id
* ionoscloud\_username
* ionoscloud\_password

```text
    extra_config_file: --extra-config EXTRA_CONFIG_FILE_PATH, -e EXTRA_CONFIG_FILE_PATH
        path to the additional config file

    snapshot_id: --snapshot-id SNAPSHOT_ID, -S SNAPSHOT_ID
        iD of the group. (required)

    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username (required)

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password (required)

    ionoscloud_url: --url URL
        the Ionoscloud API URL

```
## Example

```text
knife ionoscloud snapshot get --extra-config EXTRA_CONFIG_FILE_PATH --snapshot-id SNAPSHOT_ID --username USERNAME --password PASSWORD --url URL
```
