require 'spec_helper'

describe command('/opt/chef/embedded/bin/gem list icinga2') do
  its(:stdout) { should contain('1.0.0.pre3') }
end

describe command('icinga2 daemon -C') do
  its(:stdout) { should match('Instantiated 1 Host.') }
end
