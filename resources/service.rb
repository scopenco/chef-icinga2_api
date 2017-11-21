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

property :name, String, required: true, name_property: true
property :host_name, String, required: true
property :attributes, kind_of: Hash
property :icinga_api_host, kind_of: String, default: 'localhost'
property :icinga_api_port, kind_of: Integer, default: 5665
property :icinga_api_user, kind_of: String, default: 'admin'
property :icinga_api_pass, kind_of: String, required: true
property :icinga_api_pki_path, kind_of: String, default: '/etc/icinga2'
property :icinga_api_node_name, kind_of: String
property :icinga_cluster, kind_of: [TrueClass, FalseClass], default: false
property :icinga_satellite, kind_of: String

default_action :create

action :create do
  require 'icinga2'

  config = {
    icinga: {
      host: new_resource.icinga_api_host,
      api: {
        port: new_resource.icinga_api_port,
        user: new_resource.icinga_api_user,
        password: new_resource.icinga_api_pass,
        pki_path: new_resource.icinga_api_pki_path,
        node_name: new_resource.icinga_api_node_name,
      },
      cluster: new_resource.icinga_cluster,
      satellite: new_resource.icinga_satellite,
    },
  }
  client = Icinga2::Client.new(config)

  attributes = { name: new_resource.name, host_name: new_resource.host_name }
  attributes.merge!(new_resource.attributes)

  # set flags
  update = false
  create = false
  converge_by("Checking object Service #{new_resource.name}") do
    # check if object defined
    result = client.services(name: new_resource.name, host_name: new_resource.host_name)
    Chef::Log.debug(result.to_s)
    raise "Can't open connection to API" if result.nil? || !result.is_a?(Array)

    # for new object
    if result[0]['code'] == 404
      create = true
    else
      # Check if this object has the same settings
      attrs = result[0]['attrs']
      # check each defined attribute
      attributes.select { |k, _v| attrs.keys.include?(k.to_s) }.each do |k, v|
        # templates is Array so checking each item
        if k.to_s == 'templates'
          # check if defined template exists in object templates
          v.each { |tmpl| update = true unless attrs[k.to_s].include?(tmpl) }
        else
          update = true unless v.to_s == attrs[k.to_s].to_s
        end
      end
    end
  end

  if update
    converge_by("Removing outdated object Service #{new_resource.name}") do
      delete_service(client, new_resource.name, new_resource.host_name)
    end
  end

  if update || create
    converge_by("Creating object Service #{new_resource.name}") do
      add_service(client, attributes)
    end
  end
end

action :delete do
  require 'icinga2'

  config = {
    icinga: {
      host: new_resource.icinga_api_host,
      api: {
        port: new_resource.icinga_api_port,
        user: new_resource.icinga_api_user,
        password: new_resource.icinga_api_pass,
        pki_path: new_resource.icinga_api_pki_path,
        node_name: new_resource.icinga_api_node_name,
      },
      cluster: new_resource.icinga_cluster,
      satellite: new_resource.icinga_satellite,
    },
  }
  client = Icinga2::Client.new(config)

  # set flags
  delete = false
  converge_by("Checking object Service #{new_resource.name}") do
    # check if service exists
    result = client.services(name: new_resource.name, host_name: new_resource.host_name)
    Chef::Log.debug(result.to_s)
    raise "Can't open connection to API" if result.nil? || !result.is_a?(Array)
    delete = true if result[0]['code'] == 200
  end

  if delete
    converge_by("Removing object Service #{new_resource.name}") do
      delete_service(client, new_resource.name, new_resource.host_name)
    end
  end
end

# add icinga2 object 'Service'
def add_service(client, attributes)
  result = client.add_service(attributes)
  Chef::Log.debug(result.to_s)
  raise "Can't open connection to API" if result.nil? || !result.is_a?(Hash)
  raise "Failed to create object Service #{name}: #{result}" unless result['code'] == 200
rescue ArgumentError => err
  raise "Argument error: #{err}"
end

# delete icinga2 object 'Service'
def delete_service(client, name, host_name)
  result = client.delete_service(name: name, host_name: host_name)
  Chef::Log.debug(result.to_s)
  raise "Can't open connection to API" if result.nil? || !result.is_a?(Hash)
  raise "Failed to delete object Service #{name}: #{result}" unless [200, 404].include?(result['code'])
end