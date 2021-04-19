# RequestWait

Waits until a request status is either DONE or FAILED.

```text
knife ionoscloud request wait (options)
```

## Available options:

### Required options:

* request_id
* ionoscloud_username
* ionoscloud_password

```text
    request_id: --request-id REQUEST_ID, -R REQUEST_ID
        the ID of the Backup unit. (required)
    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username (required)
    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password (required)
```

## Example

```text
knife ionoscloud request wait --request-id REQUEST_ID --username USERNAME --password PASSWORD
```
