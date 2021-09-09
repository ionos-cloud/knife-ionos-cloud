# TemplateList

Retrieve a list of available templates. Templates can be used on specific server types only (CUBE at the moment)

```text
knife ionoscloud template list
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
knife ionoscloud template list--username USERNAME --password PASSWORD --extra-config EXTRA_CONFIG_FILE_PATH
```
