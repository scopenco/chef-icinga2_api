#
# Cookbook Name:: icinga2_api
# Resource:: icinga2_api_service
#
# Copyright 2017, Andrei Skopenko <andrei@skopenko.net>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

resource_name :icinga2_api_service

property :host_name, String, required: true, desired_state: false
property :attributes, kind_of: Hash
property :connection, Hash, required: true, desired_state: false

default_action :create

# I put this 'include' here instead of action_class because 'load_current_value'
# is using icinga2_api_conn func too.
include Icinga2ApiHelper

load_current_value do |desired|
  # Require should be here, because it will be installed in recipes before run
  require 'icinga2'

  # Get host object from API
  client = icinga2_api_conn(connection)
  result = client.services(name: name, host_name: host_name)
  raise "Can't open connection to API" if result.nil?
  raise result.to_s unless result.is_a?(Array)

  if result[0]['code'] == 404
    current_value_does_not_exist!
  else
    # Remove default 'name' value from 'templates' Array
    attrs = result[0]['attrs'].select { |k, _v| desired.attributes.keys.include?(k) }
    if desired.attributes.keys.include?('templates')
      attrs['templates'].delete(desired.name)
    end
    attributes attrs
  end
end

action :create do
  # Require should be here, because it will be installed in recipes before run
  require 'icinga2'

  converge_if_changed do
    client = icinga2_api_conn(new_resource.connection)

    converge_by "delete object Service #{new_resource.name}" do
      delete_service(client, new_resource.name, new_resource.host_name)
    end

    converge_by "create object Service #{new_resource.name}" do
      attributes = { name: new_resource.name, host_name: new_resource.host_name }
      attributes.merge!(new_resource.attributes)
      add_service(client, attributes)
    end
  end
end

action :delete do
  require 'icinga2'

  client = icinga2_api_conn(new_resource.connection)

  converge_by "delete object Host #{new_resource.name}" do
    delete_service(client, new_resource.name, new_resource.host_name)
  end
end

action_class do

  # add icinga2 object 'Service'
  def add_service(client, attributes)
    result = client.add_service(attributes)
    Chef::Log.debug(result.to_s)
    raise "Can't open connection to API" if result.nil?
    raise result.to_s unless result.is_a?(Hash)
    raise "Failed to create object Service #{name}: #{result}" unless result['code'] == 200
    Chef::Log.warn(result.to_s)
  rescue ArgumentError => err
    raise "Argument error: #{err}"
  end

  # delete icinga2 object 'Service'
  def delete_service(client, name, host_name)
    result = client.delete_service(name: name, host_name: host_name)
    Chef::Log.debug(result.to_s)
    raise "Can't open connection to API" if result.nil?
    raise result.to_s unless result.is_a?(Hash)
    raise "Failed to delete object Service #{name}: #{result}" unless [200, 404].include?(result['code'])
  end
end
