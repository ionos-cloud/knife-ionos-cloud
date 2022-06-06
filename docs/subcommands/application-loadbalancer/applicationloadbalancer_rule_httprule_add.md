# ApplicationloadbalancerRuleHttpruleAdd

Adds a Http Rule to a Application Load Balancer Forwarding Rule under a data center or updates it if one already exists.

```text
knife ionoscloud applicationloadbalancer rule httprule add (options)
```

## Available options:

### Required options:

* datacenter\_id
* application\_loadbalancer\_id
* forwarding\_rule\_id
* name
* type
* ionoscloud\_username
* ionoscloud\_password

```text
    ionoscloud_url: --url URL
        the Ionoscloud API URL

    extra_config_file: --extra-config EXTRA_CONFIG_FILE_PATH, -e EXTRA_CONFIG_FILE_PATH
        path to the additional config file

    datacenter_id: --datacenter-id DATACENTER_ID, -D DATACENTER_ID
        name of the data center (required)

    application_loadbalancer_id: --application-loadbalancer APPLICATION_LOADBALANCER_ID, -L APPLICATION_LOADBALANCER_ID
        iD of the Application Loadbalancer (required)

    forwarding_rule_id: --forwarding-rule FORWARDING_RULE_ID, -R FORWARDING_RULE_ID
        iD of the Application Loadbalancer Forwarding Rule (required)

    name: --name NAME, -n NAME
        the name of a Application Load Balancer http rule; unique per forwarding rule (required)

    type: --type TYPE, -t TYPE
        type of the Http Rule. (required)

    target_group: --target-group TARGET_GROUP_ID
        the UUID of the target group; mandatory and only valid for FORWARD action.

    drop_query: --query QUERY, -q QUERY
        default is false; valid only for REDIRECT action.

    location: --location LOCATION, -l LOCATION
        the location for redirecting; mandatory and valid only for REDIRECT action.

    status_code: --code STATUS_CODE
        valid only for action REDIRECT and STATIC; on REDIRECT action default is 301 and it can take the values 301, 302, 303, 307, 308; on STATIC action default is 503 and it can take a value between 200 and 599

    response_message: --message MESSAGE, -m MESSAGE
        the response message of the request; mandatory for STATIC action

    content_type: --content-type CONTENT_TYPE
        valid only for action STATIC

    conditions: --conditions CONDITIONS
        array of conditions for the HTTP Rule

    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username (required)

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password (required)

    ionoscloud_token: --token PASSWORD
        your Ionoscloud access token

```
## Example

```text
knife ionoscloud applicationloadbalancer rule httprule add --url URL --extra-config EXTRA_CONFIG_FILE_PATH --datacenter-id DATACENTER_ID --application-loadbalancer APPLICATION_LOADBALANCER_ID --forwarding-rule FORWARDING_RULE_ID --name NAME --type TYPE --target-group TARGET_GROUP_ID --query QUERY --location LOCATION --code STATUS_CODE --message MESSAGE --content-type CONTENT_TYPE --conditions CONDITIONS --username USERNAME --password PASSWORD --token PASSWORD
```
