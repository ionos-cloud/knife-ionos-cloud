# TargetgroupGet

Gets information about a Target Group.

```text
knife ionoscloud targetgroup get (options)
```

## Available options:

### Required options:

* target\_group\_id
* ionoscloud\_username
* ionoscloud\_password

```text
    ionoscloud_url: --url URL
        the Ionoscloud API URL

    extra_config_file: --extra-config EXTRA_CONFIG_FILE_PATH, -e EXTRA_CONFIG_FILE_PATH
        path to the additional config file

    target_group_id: --target-group-id TARGET_GROUP_ID, -T TARGET_GROUP_ID
        iD of the Target Group (required)

    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username (required)

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password (required)

    ionoscloud_token: --token PASSWORD
        your Ionoscloud access token

```
## Example

```text
knife ionoscloud targetgroup get --url URL --extra-config EXTRA_CONFIG_FILE_PATH --target-group-id TARGET_GROUP_ID --username USERNAME --password PASSWORD --token PASSWORD
```
