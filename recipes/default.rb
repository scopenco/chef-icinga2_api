#
# Cookbook Name:: icinga2_api
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

include_recipe 'build-essential'

# Install gem from fork, because icinga2 lib is not release yet
package 'git'
git '/opt/ruby-icinga2' do
  repository 'https://github.com/scopenco/ruby-icinga2.git'
  branch 'update_hosts_object'
end

execute '/opt/chef/embedded/bin/gem build icinga2.gemspec' do
  cwd '/opt/ruby-icinga2'
end

gem_package 'icinga2' do
  source '/opt/ruby-icinga2/icinga2-1.0.0.pre3.gem'
end
