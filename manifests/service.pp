# @api private
# jmeter::service
#
# @summary This class configures the service for `jmeter::server`.
#
class jmeter::service {

  assert_private()

  $bind_ip          = $jmeter::bind_ip
  $bind_port        = $jmeter::bind_port
  $jmeter_user      = $jmeter::jmeter_user
  $init_template    = $jmeter::params::init_template
  $service_provider = $jmeter::params::service_provider

  if $service_provider == 'systemd' {
    systemd::unit_file { 'jmeter.service':
      content => template('jmeter/jmeter.service.erb'),
    }
  } else {
    file { '/etc/init.d/jmeter':
      content => template($init_template),
      owner   => root,
      group   => root,
      mode    => '0755',
      notify  => Service['jmeter'],
    }
  }

  ~> service { 'jmeter':
    ensure => running,
    enable => true,
  }

  if $service_provider == 'systemd' {
    Class['systemd'] -> Service['jmeter']
  }
}
