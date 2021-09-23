# PccDelete

Deletes a Private Cross-Connect.

```text
knife ionoscloud pcc delete PCC_ID [PCC_ID]
```

## Available options:

### Required options:

* ionoscloud\_username
* ionoscloud\_password

```text
    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username (required)

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password (required)

    extra_config_file: --extra-config EXTRA_CONFIG_FILE_PATH, -e EXTRA_CONFIG_FILE_PATH
        path to the additional config file
```

## Example

```text
knife ionoscloud pcc delete PCC_ID [PCC_ID]--username USERNAME --password PASSWORD --extra-config EXTRA_CONFIG_FILE_PATH
```

