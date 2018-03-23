# icinga2_api Cookbook

[![Cookbook Version](https://img.shields.io/cookbook/v/icinga2_api.svg)](https://supermarket.chef.io/cookbooks/icinga2_api)
[![Build Status](https://secure.travis-ci.org/scopenco/chef-icinga2_api.png?branch=master)](http://travis-ci.org/scopenco/chef-icinga2_api)
[![License](https://img.shields.io/badge/license-Apache_2-blue.svg)](https://www.apache.org/licenses/LICENSE-2.0)

   * [icinga2_api Cookbook](#icinga2_api-cookbook)
      * [Description](#description)
      * [Requirements](#requirements)
         * [Cookbooks](#cookbooks)
         * [Chef](#chef)
         * [Platforms](#platforms)
      * [Recipes](#recipes)
      * [Usage](#usage)
         * [icinga2_api_host](#icinga2_api_host)
         * [icinga2_api_service](#icinga2_api_service)
      * [License &amp; Authors](#license--authors)

Created by [gh-md-toc](https://github.com/ekalinin/github-markdown-toc)

## Description

Chef cookbook with LWRPs used to interact with icinga2 API.

## Requirements

### Cookbooks

- [build-essential](https://supermarket.chef.io/cookbooks/build-essential)

### Chef

* Chef 12 or higher

### Platforms

* Debian => 6
* Ubuntu => 14.04
* RHEL => 6

**Notes**: This cookbook has been tested on the listed platforms. It may work on other platforms with or without modification.

## Recipes

* `default` - installing [icinga2](https://github.com/bodsch/ruby-icinga2/) gem for LWRPs.

## Usage

The main use case is to create icinga2 objects on the node bootstrap time. Thus you don't need to create any autodiscovery tools that will describe all nodes in icinga2 setup.
Please refer to [integration cookbook](https://github.com/scopenco/chef-icinga2_api/blob/master/test/fixtures/cookbooks/test/recipes/default.rb) for examples.

### icinga2_api_host

LWRP `host` creates an icinga `Host` object.

**LWRP Environment Host example**

```
# Set connection to icinga2 API
icinga2_api = {
    host: '127.0.0.1',
    username: 'admin',
    password: 'mysecret',
    node_name: 'master',
    cluster: true,
    satellite: 'master',
}

icinga2_api_host 'host1' do
  attributes 'address' => '127.0.0.1',
	     'templates' => ['check-host-tmpl-30s'],
	     'vars' => {
		'myvar' => 'mygroup',
	      }
  connection icinga2_api
end
```

**LWRP Options**

- *name* (name_attribute, String)           - chef resource name and icinga2 host name.
- *attributes* (optional, Hash)             - icinga2 host object attributes.
- *connection* (optional, Hash)             - icinga2 API connection settings.
- *action* (optional)                       - options: [:create, :delete], default :create.

### icinga2_api_service

LWRP `service` creates an icinga `Service` object.

**LWRP Environment Service example**

```
# Set connection to icinga2 API
icinga2_api = {
    host: '127.0.0.1',
    username: 'admin',
    password: 'mysecret',
    node_name: 'master',
    cluster: true,
    satellite: 'master',
}

icinga2_api_service 'host1_ping1' do
  host_name 'host1'
  attributes 'templates' => ['check-service-tmpl-30s'],
             'display_name' => 'PING1',
             'check_command' => 'hostalive'
  connection icinga2_api
end
```

**LWRP Options**

- *name* (name_attribute, String)           - chef resource name and icinga2 service name. Should be unique in icinga2 setup.
- *host_name* (required, Hash)              - icinga2 host name object attributes.
- *attributes* (optional, Hash)             - icinga2 service object attributes.
- *connection* (optional, Hash)             - icinga2 API connection settings.
- *action* (optional)                       - options: [:create, :delete], default :create.

## License & Authors
- Author:: Andrei Skopenko <andrei@skopenko.net>

```text
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
