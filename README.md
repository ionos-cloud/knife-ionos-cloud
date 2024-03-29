# Knife Plugin for IONOS Cloud

![CI](https://github.com/ionos-cloud/knife-ionos-cloud/workflows/CI/badge.svg) 
[![Gem Version](https://badge.fury.io/rb/knife-ionoscloud.svg)](https://badge.fury.io/rb/knife-ionoscloud) 
[![Gitter](https://badges.gitter.im/ionos-cloud/sdk-general.png)](https://gitter.im/ionos-cloud/sdk-general)
[![Quality Gate Status](https://sonarcloud.io/api/project_badges/measure?project=knife-plugin&metric=alert_status)](https://sonarcloud.io/dashboard?id=knife-plugin)
[![Bugs](https://sonarcloud.io/api/project_badges/measure?project=knife-plugin&metric=bugs)](https://sonarcloud.io/dashboard?id=knife-plugin)
[![Maintainability Rating](https://sonarcloud.io/api/project_badges/measure?project=knife-plugin&metric=sqale_rating)](https://sonarcloud.io/dashboard?id=knife-plugin)
[![Reliability Rating](https://sonarcloud.io/api/project_badges/measure?project=knife-plugin&metric=reliability_rating)](https://sonarcloud.io/dashboard?id=knife-plugin)
[![Security Rating](https://sonarcloud.io/api/project_badges/measure?project=knife-plugin&metric=security_rating)](https://sonarcloud.io/dashboard?id=knife-plugin)
[![Vulnerabilities](https://sonarcloud.io/api/project_badges/measure?project=knife-plugin&metric=vulnerabilities)](https://sonarcloud.io/dashboard?id=knife-plugin)

## Overview

Chef is a popular configuration management tool that allows simplified configuration and maintenance of both servers and cloud provider environments through the use of common templates called recipes. The Chef `knife` command line tool allows management of various nodes within those environments. The `knife-ionoscloud` plugin utilizes the IONOS Cloud REST API to provision and manage various cloud resources on the IONOS Cloud platform.

In depth documaentation can be found at [here](https://docs.ionos.com/knife-plugin).


## Getting Started

An IONOS account is required for access to the Cloud API; credentials from your registration are used to authenticate against the IONOS Cloud API.

### Installation

The `knife-ionoscloud` plugin can be installed as a gem:

```text
$ gem install knife-ionoscloud
```

Or the plugin can be installed by adding the following line to your application's Gemfile:

```text
gem 'knife-ionoscloud'
```

And then execute:

```text
$ bundle
```

### Configuration

The Ionoscloud account credentials can be added to the `knife.rb` configuration file.

```text
knife[:ionoscloud_username] = 'username'
knife[:ionoscloud_password] = 'password'
```

If a virtual data center has already been created under the Ionoscloud account, then the data center UUID can be added to the `knife.rb` which reduces the need to include the `--datacenter-id [datacenter_id]` parameter for each action within the data center.

```text
knife[:datacenter_id] = 'f3f3b6fe-017d-43a3-b42a-a759144b2e99'

knife[:ionoscloud_debug] = true
```

The configuration parameters can also be passed using shell environment variables. First, the following should be added to the `knife.rb` configuration file:

```text
knife[:ionoscloud_username] = ENV['IONOSCLOUD_USERNAME']
knife[:ionoscloud_password] = ENV['IONOSCLOUD_PASSWORD']
```

Now the parameters can be set as environment variables:

```text
$ export IONOSCLOUD_USERNAME='username'
$ export IONOSCLOUD_PASSWORD='password'
```

### Testing

```text
$ rspec spec
```

Bugs & feature requests can be open on the repository issues: [https://github.com/ionos-cloud/knife-ionos-cloud/issues/new/choose](https://github.com/ionos-cloud/knife-ionos-cloud/issues/new/choose)
