# ResourceList

No option: Retrieves a list of all resources and optionally their group associations. Please Note: This API call can take a significant amount of time to return when there are a large number of provisioned resources. You may wish to consult the next section on how to list resources of a particular type.



```text
knife ionoscloud resource list (options)
```

## Available options:

### Required options:


```text
    ionoscloud_url: --url URL
        the Ionoscloud API URL

    extra_config_file: --extra-config EXTRA_CONFIG_FILE_PATH, -e EXTRA_CONFIG_FILE_PATH
        path to the additional config file

    resource_type: --resource-type RESOURCE_TYPE, -t RESOURCE_TYPE
        the specific type of resources to retrieve information about.

    resource_id: --resource-id RESOURCE_ID, -R RESOURCE_ID
        the ID of the specific resource to retrieve information about.

    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password

    ionoscloud_token: --token PASSWORD
        your Ionoscloud access token

```
## Example

```text
knife ionoscloud resource list --url URL --extra-config EXTRA_CONFIG_FILE_PATH --resource-type RESOURCE_TYPE --resource-id RESOURCE_ID --username USERNAME --password PASSWORD --token PASSWORD
```
