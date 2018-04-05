#
# Cookbook Name:: icinga2_api
# Library:: helpers
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

module Icinga2ApiHelper
  ## TODO disable reloading API
  # Prepate client object
  def icinga2_api_conn(conn)
    config = {
      icinga: {
        host: conn[:host],
        api: {
          port: conn[:port],
          username: conn[:username],
          password: conn[:password],
          pki_path: conn[:pki_path],
          node_name: conn[:node_name],
        },
        cluster: conn[:cluster],
        satellite: conn[:satellite],
      },
    }
    Icinga2::Client.new(config)
  end

  # add icinga2 object 'Service'
  def add_service(client, attributes)
    result = client.add_service(attributes)
    Chef::Log.debug(result.to_s)
    raise "Can't open connection to API" if result.nil?
    raise result.to_s unless result.is_a?(Hash)
    raise "Failed to create object Service #{name}: #{result}" unless result['code'] == 200
  rescue ArgumentError => err
    raise "Argument error: #{err}"
  end

  # delete icinga2 object 'Service'
  def delete_service(client, name, host_name)
    result = client.delete_service(name: name, host_name: host_name, cascade: true)
    Chef::Log.debug(result.to_s)
    raise "Can't open connection to API" if result.nil?
    raise result.to_s unless result.is_a?(Hash)
    raise "Failed to delete object Service #{name}: #{result}" unless [200, 404].include?(result['code'])
  end

  # add icinga2 object 'Host'
  def add_host(client, attributes)
    result = client.add_host(attributes)
    Chef::Log.debug(result.to_s)
    raise "Can't open connection to API" if result.nil?
    raise result.to_s unless result.is_a?(Hash)
    raise "Failed to create object Host #{name}: #{result}" unless result['code'] == 200
  rescue ArgumentError => err
    raise "Argument error: #{err}"
  end

  # delete icinga2 object 'Host'
  def delete_host(client, name)
    result = client.delete_host(name: name, cascade: true)
    Chef::Log.debug(result.to_s)
    raise "Can't open connection to API" if result.nil?
    raise result.to_s unless result.is_a?(Hash)
    raise "Failed to delete object Host #{name}: #{result}" unless [200, 404].include?(result['code'])
  end
end
