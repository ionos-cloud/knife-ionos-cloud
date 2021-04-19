# SnapshotDelete

Deletes the specified snapshot.

```text
knife ionoscloud snapshot delete SNAPSHOT_ID [SNAPSHOT_ID]
```

## Available options:
---

### Required options:

* ionoscloud_username
* ionoscloud_password

```text
    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username (required)

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password (required)

```

## Example

```text
knife ionoscloud snapshot delete SNAPSHOT_ID [SNAPSHOT_ID]--username USERNAME --password PASSWORD
```
