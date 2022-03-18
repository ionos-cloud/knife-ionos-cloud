# DatacenterList

Ionoscloud introduces the concept of virtual data centers. These are logically separated from one another and allow you to have a self-contained environment for all servers, volumes, networking, and other resources. The goal is to give you the same experience as you would have if you were running your own physical data center. A list of available data centers can be obtained with the following command.

```text
knife ionoscloud datacenter list
```

## Available options:

### Required options:

* ionoscloud\_username
* ionoscloud\_password

```text
    extra_config_file: --extra-config EXTRA_CONFIG_FILE_PATH, -e EXTRA_CONFIG_FILE_PATH
        path to the additional config file

    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username (required)

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password (required)

    ionoscloud_url: --url URL
        the Ionoscloud API URL

```
## Example

```text
knife ionoscloud datacenter list--extra-config EXTRA_CONFIG_FILE_PATH --username USERNAME --password PASSWORD --url URL
```
