# TargetgroupTargetRemove

Removes a Target from a Target Group if it exists.

```text
knife ionoscloud targetgroup target remove (options)
```

## Available options:

### Required options:

* target\_group\_id
* ip
* port
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

    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username (required)

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password (required)

    ionoscloud_token: --token PASSWORD
        your Ionoscloud access token

```
## Example

```text
knife ionoscloud targetgroup target remove --url URL --extra-config EXTRA_CONFIG_FILE_PATH --target-group-id TARGET_GROUP_ID --ip IP --port PORT --username USERNAME --password PASSWORD --token PASSWORD
```
