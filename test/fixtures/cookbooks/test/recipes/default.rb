#
# Cookbook Name:: test
# Recipe:: default
#
# Copyright 2017 Andrei Skopenko
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

node.default['icinga2']['ignore_version'] = true
include_recipe 'icinga2::attributes'
include_recipe 'icinga2::core_install'
include_recipe 'icinga2::server_config'
include_recipe 'icinga2::service'

icinga2_host 'check-host-tmpl-30s' do
  template true
  max_check_attempts 5
  check_interval '30s'
  retry_interval '5s'
  check_command 'hostalive'
end

icinga2_service 'check-service-tmpl-30s' do
  template true
  max_check_attempts 3
  check_interval '30s'
  retry_interval '10s'
end

# setup icinga2 endpoint for API
icinga2_endpoint 'localhost' do
  host '127.0.0.1'
end

# add zone for master
icinga2_zone 'localhost' do
  endpoints ['localhost']
end

# setup API
ca_crt = File.join(node['icinga2']['lib_dir'], 'ca/ca.crt')
ca_key = File.join(node['icinga2']['lib_dir'], 'ca/ca.key')
client_key = File.join(node['icinga2']['pki_dir'], 'localhost.key')
client_crt = File.join(node['icinga2']['pki_dir'], 'localhost.crt')
client_csr = File.join(node['icinga2']['pki_dir'], 'localhost.csr')

# Create ssl certs
bash 'Generate self signed ca' do
  code 'icinga2 pki new-ca'
  not_if { ::File.exist?(ca_key) }
end

bash 'Generate self signed crt/key' do
  code 'icinga2 pki new-cert --cn localhost ' \
       "--key #{client_key} " \
       "--csr #{client_csr}"
  not_if { ::File.exist?(client_csr) }
end

bash 'Sign self signed crt/key' do
  code 'icinga2 pki sign-csr ' \
       "--csr #{client_csr} " \
       "--cert #{client_crt}"
  not_if { ::File.exist?(client_crt) }
end

# setup API Listener
icinga2_apilistener 'localhost' do
  cert_path "\"#{client_crt}\""
  key_path "\"#{client_key}\""
  ca_path "\"#{ca_crt}\""
  bind_host '127.0.0.1'
  bind_port 5665
  ticket_salt 'TicketSalt'
end

icinga2_apiuser 'admin' do
  password 'mysecret'
  permissions '["*"]'
  notifies :restart, 'service[icinga2]', :immediately
end

include_recipe 'icinga2_api'

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

icinga2_api_host 'host2' do
  attributes 'address' => '127.0.0.1',
             'templates' => ['check-host-tmpl-30s'],
             'vars' => {
               'myvar' => 'mygroup',
             }
  connection icinga2_api
end

icinga2_api_service 'host2_ping' do
  host_name 'host2'
  attributes 'templates' => ['check-service-tmpl-30s'],
             'display_name' => 'PING',
             'check_command' => 'hostalive'
  connection icinga2_api
end

icinga2_api_host 'host2' do
  connection icinga2_api
  action :delete
end

icinga2_api_service 'host1_ping1' do
  host_name 'host1'
  attributes 'templates' => ['check-service-tmpl-30s'],
             'display_name' => 'PING1',
             'check_command' => 'hostalive'
  connection icinga2_api
end

icinga2_api_service 'host1_ping2' do
  host_name 'host1'
  connection icinga2_api
  action :delete
end
