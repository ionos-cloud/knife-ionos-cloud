# Ionoscloud Chef Knife Plugin

## Overview

Chef is a popular configuration management tool that allows simplified configuration and maintenance of both servers and cloud provider environments through the use of common templates called recipes. The Chef `knife` command line tool allows management of various nodes within those environments. The `knife-ionoscloud` plugin utilizes the Ionoscloud REST API to provision and manage various cloud resources on the Ionoscloud platform.

## Getting Started

Before you begin you will need to have [signed-up](https://www.ionos.com/enterprise-cloud/signup) for a Ionoscloud account. The credentials you establish during sign-up will be used to authenticate against the [Ionoscloud Cloud API](https://devops.ionos.com/api/).

### Installation

The `knife-ionoscloud` plugin can be installed as a gem:

    $ gem install knife-ionoscloud

Or the plugin can be installed by adding the following line to your application's Gemfile:

    gem 'knife-ionoscloud'

And then execute:

    $ bundle

### Configuration

The Ionoscloud account credentials can be added to the `knife.rb` configuration file.

    knife[:ionoscloud_username] = 'username'
    knife[:ionoscloud_password] = 'password'

If a virtual data center has already been created under the Ionoscloud account, then the data center UUID can be added to the `knife.rb` which reduces the need to include the `--datacenter-id [datacenter_id]` parameter for each action within the data center.

    knife[:datacenter_id] = 'f3f3b6fe-017d-43a3-b42a-a759144b2e99'

    knife[:ionoscloud_debug] = true

The configuration parameters can also be passed using shell environment variables. First, the following should be added to the `knife.rb` configuration file:

    knife[:ionoscloud_username] = ENV['IONOSCLOUD_USERNAME']
    knife[:ionoscloud_password] = ENV['IONOSCLOUD_PASSWORD']

Now the parameters can be set as environment variables:

    $ export IONOSCLOUD_USERNAME='username'
    $ export IONOSCLOUD_PASSWORD='password'

### Testing

    $ rspec spec

## Feature Reference

The IONOS Cloud plugin for Knife aims to offer access to all resources in the IONOS Cloud API and also offers some additional features that make the integration easier:

* authentication for API calls
* handling of asynchronous requests 

## FAQ

1. How can I open a bug/feature request? 

Bugs & feature requests can be open on the repository issues: [https://github.com/ionos-cloud/knife-ionos-cloud/issues/new/choose](https://github.com/ionos-cloud/knife-ionos-cloud/issues/new/choose)