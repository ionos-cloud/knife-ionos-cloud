# RequestList

This operation allows you to retrieve a list of requests. Cloud API calls generate a request which is assigned an id. This "request id" can be used to get information about the request and its current status. The "list request" operation described here will return an array of request items. Each returned request item will have an id that can be used to get additional information as described in the Get Request and Get Request Status sections.

```text
knife ionoscloud request list (options)
```

## Available options:

### Required options:


```text
    ionoscloud_url: --url URL
        the Ionoscloud API URL

    extra_config_file: --extra-config EXTRA_CONFIG_FILE_PATH, -e EXTRA_CONFIG_FILE_PATH
        path to the additional config file

    limit: --limit LIMIT, -l LIMIT
        the maximum number of requests to look into.

    offset: --offset OFFSET, -o OFFSET
        the request number from which to return results.

    status: --status STATUS, -s STATUS
        request status filter to fetch all the request based on a particular status [QUEUED, RUNNING, DONE, FAILED]

    method: --method METHOD, -m METHOD
        request method filter to fetch all the request based on a particular method [POST, PUT, PATCH, DELETE]

    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password

    ionoscloud_token: --token PASSWORD
        your Ionoscloud access token

```
## Example

```text
knife ionoscloud request list --url URL --extra-config EXTRA_CONFIG_FILE_PATH --limit LIMIT --offset OFFSET --status STATUS --method METHOD --username USERNAME --password PASSWORD --token PASSWORD
```
