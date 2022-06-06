# TargetgroupUpdate

Updates information about a Ionoscloud Application LoadBalancer.

```text
knife ionoscloud targetgroup update (options)
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

    name: --name NAME, -n NAME
        name of the server

    algorithm: --algorithm ALGORITHM, -a ALGORITHM
        algorithm for the balancing. One of ["ROUND_ROBIN", "LEAST_CONNECTION", "RANDOM", "SOURCE_IP"]

    protocol: --protocol PROTOCOL, -p PROTOCOL
        protocol of the balancing. One of ["HTTP"]

    check_timeout: --check-timeout CHECK_TIMEOUT
        it specifies the time (in milliseconds) for a target VM in this pool to answer the check. If a target VM has CheckInterval set and CheckTimeout is set too, then the smaller value of the two is used after the TCP connection is established.

    check_interval: --check-interval check_interval
        it specifies the maximum time (in milliseconds) to wait for a connection attempt to a target VM to succeed. If unset, the default of 5 seconds will be used.

    retries: --retries RETRIES, -r RETRIES
        retries specifies the number of retries to perform on a target VM after a connection failure. If unset, the default value of 3 will be used. (valid range: [0, 65535])

    path: --path PATH
        the path for the HTTP health check; default: /.

    method: --method METHOD, -m METHOD
        the method for the HTTP health check.

    match_type: --match-type MATCH_TYPE
        the method for the HTTP health check. One of ["STATUS_CODE", "RESPONSE_BODY"].

    response: --response RESPONSE
        the response returned by the request.

    regex: --regex REGEX
        the regex used.

    negate: --negate
        whether to negate or not.

    targets: --targets
        array of TargetGroup targets.

    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username (required)

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password (required)

    ionoscloud_token: --token PASSWORD
        your Ionoscloud access token

```
## Example

```text
knife ionoscloud targetgroup update --url URL --extra-config EXTRA_CONFIG_FILE_PATH --target-group-id TARGET_GROUP_ID --name NAME --algorithm ALGORITHM --protocol PROTOCOL --check-timeout CHECK_TIMEOUT --check-interval check_interval --retries RETRIES --path PATH --method METHOD --match-type MATCH_TYPE --response RESPONSE --regex REGEX --negate --targets --username USERNAME --password PASSWORD --token PASSWORD
```
