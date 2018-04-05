name             'icinga2_api'
maintainer       'Andrei Skopenko'
maintainer_email 'andrey@skopenko.net'
license          'Apache-2.0'
description      'Chef LWRPs to interact with Icinga2 API'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
source_url 'https://github.com/scopenco/chef-icinga2_api'
issues_url 'https://github.com/scopenco/chef-icinga2_api/issues'
version '1.0.3'

supports 'amazon'
supports 'redhat'
supports 'centos'
supports 'scientific'
supports 'fedora'
supports 'debian'
supports 'ubuntu'

depends 'build-essential'
