# ApplicationloadbalancerRuleHttpruleRemove

Removes a Http Rule from a Application Load Balancer Forwarding Rule.

```text
knife ionoscloud applicationloadbalancer rule httprule remove HTTP_RULE_NAME [HTTP_RULE_NAME] (options)
```

## Available options:

### Required options:

* datacenter\_id
* application\_loadbalancer\_id
* forwarding\_rule\_id
* ionoscloud\_username
* ionoscloud\_password

```text
    extra_config_file: --extra-config EXTRA_CONFIG_FILE_PATH, -e EXTRA_CONFIG_FILE_PATH
        path to the additional config file

    datacenter_id: --datacenter-id DATACENTER_ID, -D DATACENTER_ID
        name of the data center (required)

    application_loadbalancer_id: --application-loadbalancer APPLICATION_LOADBALANCER_ID, -L APPLICATION_LOADBALANCER_ID
        iD of the Application Loadbalancer (required)

    forwarding_rule_id: --forwarding-rule FORWARDING_RULE_ID, -R FORWARDING_RULE_ID
        iD of the Application Loadbalancer Forwarding Rule (required)

    ionoscloud_username: --username USERNAME, -u USERNAME
        your Ionoscloud username (required)

    ionoscloud_password: --password PASSWORD, -p PASSWORD
        your Ionoscloud password (required)

    ionoscloud_url: --url URL
        the Ionoscloud API URL

```
## Example

```text
knife ionoscloud applicationloadbalancer rule httprule remove HTTP_RULE_NAME 
```
