require 'beaker-rspec'
require 'beaker/puppet_install_helper'

UNSUPPORTED_PLATFORMS = ['windows', 'Darwin', 'Solaris']

unless ENV['RS_PROVISION'] == 'no' or ENV['BEAKER_provision'] == 'no'

  run_puppet_install_helper

  hosts.each do |host|
    # for now we have to use unreleased versions of stdlib and tea for testing
    apply_manifest_on(host, 'package { "git": }')
    environmentpath = host.puppet['environmentpath']
    environmentpath = environmentpath.split(':').first if environmentpath

    on host, puppet('module install puppetlabs-stdlib')
    on host, puppet('module install puppet-archive')
  end
end

RSpec.configure do |c|
  # Project root
  proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))

  # Readable test descriptions
  c.formatter = :documentation

  # Configure all nodes in nodeset
  c.before :suite do
    hosts.each do |host|
      copy_module_to(host, :source => proj_root, :module_name => 'jmeter')
    end
  end
end
