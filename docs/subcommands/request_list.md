# RequestList

This operation allows you to retrieve a list of requests. Cloud API calls generate a request which is assigned an id. This &quot;request id&quot; can be used to get information about the request and its current status. The &quot;list request&quot; operation described here will return an array of request items. Each returned request item will have an id that can be used to get additional information as described in the Get Request and Get Request Status sections.

    knife ionoscloud request list (options)


## Available options:
---

### Required options:
* ionoscloud_username
* ionoscloud_password

```
    limit: --limit LIMIT, -l LIMIT
        the maximum number of results.

    offset: --offset OFFSET, -o OFFSET
        the request number from which to return results.

    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username (required)

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password (required)

```

## Example

    knife ionoscloud request list --limit LIMIT --offset OFFSET --username USERNAME --password PASSWORD
