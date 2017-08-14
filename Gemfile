source 'https://rubygems.org'

gem 'puppetlabs_spec_helper', :groups => [:test]

if facterversion = ENV['FACTER_GEM_VERSION']
    gem 'facter', facterversion.to_s, :require => false, :groups => [:test]
else
    gem 'facter', :require => false, :groups => [:test]
end

ENV['PUPPET_GEM_VERSION'].nil? ? puppetversion = '~> 4.0' : puppetversion = ENV['PUPPET_GEM_VERSION'].to_s
gem 'puppet', puppetversion, :require => false, :groups => [:test]

gem 'puppet-lint', :require => false, :groups => [:development]
gem 'metadata-json-lint', :require => false, :groups => [:development], :platforms => 'ruby'
gem 'puppet-blacksmith', '>= 3.4.0', :require => false, :groups => [:development], :platforms => 'ruby'
gem 'semantic_puppet'

# Find a location or specific version for a gem. place_or_version can be a
# version, which is most often used. It can also be git, which is specified as
# `git://somewhere.git#branch`. You can also use a file source location, which
# is specified as `file://some/location/on/disk`.
def location_for(place_or_version, fake_version = nil)
  if place_or_version =~ /^(git[:@][^#]*)#(.*)/
    [fake_version, { :git => $1, :branch => $2, :require => false }].compact
  elsif place_or_version =~ /^file:\/\/(.*)/
    ['>= 0', { :path => File.expand_path($1), :require => false }]
  else
    [place_or_version, { :require => false }]
  end
end

# Used for gem conditionals
supports_windows = false

group :system_tests do
  gem 'beaker', *location_for(ENV['BEAKER_VERSION'] || '~> 2.20')                if supports_windows
  gem 'beaker', *location_for(ENV['BEAKER_VERSION'])                             if Gem::Version.new(RUBY_VERSION.dup) >= Gem::Version.new('2.3.0') and ! supports_windows
  gem 'beaker', *location_for(ENV['BEAKER_VERSION'] || '< 3')                    if Gem::Version.new(RUBY_VERSION.dup) < Gem::Version.new('2.3.0') and ! supports_windows
  gem 'beaker-pe',                                                               :require => false if Gem::Version.new(RUBY_VERSION.dup) >= Gem::Version.new('2.3.0')
  gem 'beaker-rspec', *location_for(ENV['BEAKER_RSPEC_VERSION'] || '>= 3.4')     if ! supports_windows
  gem 'beaker-rspec', *location_for(ENV['BEAKER_RSPEC_VERSION'] || '~> 5.1')     if supports_windows
  gem 'beaker-puppet_install_helper',                                            :require => false
  gem 'master_manipulator',                                                      :require => false
  gem 'beaker-hostgenerator', *location_for(ENV['BEAKER_HOSTGENERATOR_VERSION'])
  gem 'beaker-abs', *location_for(ENV['BEAKER_ABS_VERSION'] || '~> 0.1')        
end