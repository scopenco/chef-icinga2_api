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

require 'icinga2'

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
end
