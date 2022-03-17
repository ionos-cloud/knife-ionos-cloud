# Introduction

![CI](https://github.com/ionos-cloud/knife-ionos-cloud/workflows/CI/badge.svg) [![Gem Version](https://badge.fury.io/rb/knife-ionoscloud.svg)](https://badge.fury.io/rb/knife-ionoscloud) [![Gitter](https://badges.gitter.im/ionos-cloud/sdk-general.png)](https://gitter.im/ionos-cloud/sdk-general)

---
**NOTE:**
Be aware that the Chef IonosCloud Provider v6 will become main branch and it will be using the latest stable API Version.

---

## Overview

Chef is a popular configuration management tool that allows simplified configuration and maintenance of both servers and cloud provider environments through the use of common templates called recipes. The Chef `knife` command line tool allows management of various nodes within those environments. The `knife-ionoscloud` plugin utilizes the IONOS Cloud REST API to provision and manage various cloud resources on the IONOS Cloud platform.

## Getting Started

An IONOS account is required for access to the Cloud API; credentials from your registration are used to authenticate against the IONOS Cloud API.

### Installation

The `knife-ionoscloud` plugin can be installed as a gem:

```shell
$ gem install knife-ionoscloud
```

Or the plugin can be installed by adding the following line to your application's Gemfile:

```gemfile
gem 'knife-ionoscloud'
```

And then execute:

```shell
$ bundle
```

### Configuration

The Ionoscloud account credentials can be added to the `knife.rb` configuration file.

```ruby
knife[:ionoscloud_username] = 'username'
knife[:ionoscloud_password] = 'password'
```

If a virtual data center has already been created under the Ionoscloud account, then the data center UUID can be added to the `knife.rb` which reduces the need to include the `--datacenter-id [datacenter_id]` parameter for each action within the data center.

```ruby
knife[:datacenter_id] = 'f3f3b6fe-017d-43a3-b42a-a759144b2e99'

knife[:ionoscloud_debug] = true
```

The configuration parameters can also be passed using shell environment variables. First, the following should be added to the `knife.rb` configuration file:

```ruby
knife[:ionoscloud_username] = ENV['IONOSCLOUD_USERNAME']
knife[:ionoscloud_password] = ENV['IONOSCLOUD_PASSWORD']
```

Now the parameters can be set as environment variables:

```shell
$ export IONOSCLOUD_USERNAME='username'
$ export IONOSCLOUD_PASSWORD='password'
```

Instead of using username and password to authenticate, one can a Ionoscloud access token, setting it using the :ionoscloud_token argument:.

```ruby
knife[:ionoscloud_token] = '<token>'
```

**Be aware that setting the token makes the username and password be ignored, in order to use the username nad password one must unset the token value.**

### Testing

```shell
$ rspec spec
```

### Getting input from a file

In order to make passing JSON or array arguments easier, we allow you to specify a file which holds the arguments for a command. This is done with the
`--extra-config EXTRA_CONFIG_FILE_PATH` or `-e EXTRA_CONFIG_FILE_PATH`. The file is expected to contain a JSON which should map the name of arguments to their expected values. Here is an example of such a file.

```json
{
  "ionoscloud_username": "username",
  "ionoscloud_password": "password",
  "name": "test_datacenter_name",
  "location": "de/txl"
}
```

When using the command `knife ionoscloud datacenter create --extra-config EXTRA_CONFIG_FILE_PATH` where EXTRA_CONFIG_FILE_PATH is the name of the file containing the JSON above, the arguments described in the file will be used. 

* If any of the arguments are set in any other way, the values from the file will be ignored. Running the command `knife ionoscloud datacenter create --location us/las --extra-config EXTRA_CONFIG_FILE_PATH` will create a datacenter in the 'us/las' location. In the same way if the values for ionoscloud_username and ionoscloud_password are already set in the knife.rb file, the contents from the JSON will be ignored.
* Only Ionoscloud specific options may be altered using this option.
* If an option is ignored because it is not on the available options list or if it is overwritten in another way then a warning message will be displayed.

### Changing the API url

By changing API url the module will make all calls using the provided url. To change the API url used by the knife module, one can do either of the following:
* specify the new url using `--url NEW_URL`
* set it in a json file, using the `ionoscloud_url` key, and passing the file to the command like described in the section above
* set the new url in the knife.rb file. It could be set using an environmental variable, same as with the username and the password.

```text
knife[:ionoscloud_url] = NEW_API_URL
```

## Feature Reference

The IONOS Cloud plugin for Knife aims to offer access to all resources in the IONOS Cloud API and also offers some additional features that make the integration easier:

* authentication for API calls
* handling of asynchronous requests 

## FAQ

1. How can I open a bug/feature request?

Bugs & feature requests can be open on the repository issues: [https://github.com/ionos-cloud/knife-ionos-cloud/issues/new/choose](https://github.com/ionos-cloud/knife-ionos-cloud/issues/new/choose)

