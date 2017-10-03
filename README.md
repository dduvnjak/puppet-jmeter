# Puppet JMeter

[![Build Status](https://travis-ci.org/dduvnjak/puppet-jmeter.svg?branch=master)](https://travis-ci.org/dduvnjak/puppet-jmeter)
[![Puppet Forge](https://img.shields.io/puppetforge/v/dduvnjak/jmeter.svg)](https://forge.puppet.com/dduvnjak/jmeter)
[![Puppet Forge - downloads](https://img.shields.io/puppetforge/dt/dduvnjak/jmeter.svg)](https://forge.puppetlabs.com/dduvnjak/jmeter)

This class installs the latest version of JMeter (currently v3.2) from apache.org. If you set the `enable_server` parameter, an init script will be installed, the service enabled, and JMeter will be started in server mode listening on the default port.

`jmeter` can optionally install the plugin manager, which allows you to install additional plugins.

The init script is based on the one available at https://gist.github.com/2830209.

Note: If you are using 3.x (the default version), you will need to have at least Java 8 installed.

Basic usage
-----------

Install JMeter:

    class { 'jmeter': }

Install JMeter v3.x, plugin manager ([JMeterPlugins](http://jmeter-plugins.org/), and enable the most recent version of plugins 'foo' and 'bar'. 

    class { 'jmeter':
      jmeter_version         => '3.2',
      plugin_manager_install => true,
      plugins                => {
        'foo' => { ensure => present },
        'bar' => { ensure => present },
      }
    }

Install JMeter server using the default host-only IP address 0.0.0.0:

    class { 'jmeter':
      enable_server => true,
    }

Install JMeter server using a custom host-only IP address:

    class { 'jmeter':
      enable_server => true,
      bind_ip       => '10.33.33.42',
    }

Install a plugin (if not using the `jmeter::plugins` example above):

    jmeter_plugin { 'foo':
      ensure => present,
    }


