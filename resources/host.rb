#
# Cookbook Name:: icinga2_api
# Resource:: icinga2_api_host
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

resource_name :icinga2_api_host

property :name, String, required: true, name_property: true
property :options, kind_of: Hash
property :icinga_host, kind_of: String, default: 'localhost'
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
      host: new_resource.icinga_host,
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

  options = { name: new_resource.name }
  options.merge!(new_resource.options)

  # set flags
  update = false
  create = false
  converge_by("Checking object Host #{new_resource.name}") do
    # check if object defined
    result = client.hosts(name: new_resource.name)
    raise "Can't open connection to API" if result.nil? || !result.is_a?(Array)

    # for new object
    if result[0]['code'] == 404
      create = true
    else
      # Check if this object has the same settings
      attrs = result[0]['attrs']
      # check each defined attribute
      options.select { |k, _v| attrs.keys.include?(k.to_s) }.each do |k, v|
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
    converge_by("Removing outdated object Host #{new_resource.name}") do
      delete_host(client, new_resource.name)
    end
  end

  if update || create
    converge_by("Creating object Host #{new_resource.name}") do
      begin
        client.add_host(options)
      rescue ArgumentError => err
        raise "Argument error: #{err}"
      end
    end
  end
end

action :delete do
  require 'icinga2'

  config = {
    icinga: {
      host: new_resource.icinga_host,
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

  converge_by("Removing object Host #{new_resource.name}") do
    delete_host(client, new_resource.name)
  end
end

def delete_host(client, name)
  result = client.delete_host(name: name)
  raise "Can't open connection to API" if result.nil? || !result.is_a?(Hash)
  raise "Failed to delete object Host #{name}: #{result}" unless [200, 404].include?(result['code'])
end
