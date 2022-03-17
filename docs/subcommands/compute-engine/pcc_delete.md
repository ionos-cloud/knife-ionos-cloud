# PccDelete

Deletes a Private Cross-Connect.

```text
knife ionoscloud pcc delete PCC_ID [PCC_ID]
```

## Available options:

### Required options:


```text
    ionoscloud_url: --url URL
        the Ionoscloud API URL

    extra_config_file: --extra-config EXTRA_CONFIG_FILE_PATH, -e EXTRA_CONFIG_FILE_PATH
        path to the additional config file

    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password

    ionoscloud_token: --token PASSWORD
        your Ionoscloud access token

```
## Example

```text
knife ionoscloud pcc delete PCC_ID [PCC_ID]--url URL --extra-config EXTRA_CONFIG_FILE_PATH --username USERNAME --password PASSWORD --token PASSWORD
```
