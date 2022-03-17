# SnapshotGet

Retrieves the attributes of a given Snapshot.

```text
knife ionoscloud snapshot get (options)
```

## Available options:

### Required options:

* snapshot\_id

```text
    ionoscloud_url: --url URL
        the Ionoscloud API URL

    extra_config_file: --extra-config EXTRA_CONFIG_FILE_PATH, -e EXTRA_CONFIG_FILE_PATH
        path to the additional config file

    snapshot_id: --snapshot-id SNAPSHOT_ID, -S SNAPSHOT_ID
        iD of the group. (required)

    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password

    ionoscloud_token: --token PASSWORD
        your Ionoscloud access token

```
## Example

```text
knife ionoscloud snapshot get --url URL --extra-config EXTRA_CONFIG_FILE_PATH --snapshot-id SNAPSHOT_ID --username USERNAME --password PASSWORD --token PASSWORD
```
