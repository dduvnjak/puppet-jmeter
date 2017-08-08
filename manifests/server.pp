# jmeter::server
#
# @summary This class configures the server component of JMeter. Private class.
#
class jmeter::server {

  assert_private()

  $bind_ip = $::jmeter::bind_ip

  $init_template = $::jmeter::params::init_template

  file { '/etc/init.d/jmeter':
    content => template($init_template),
    owner   => root,
    group   => root,
    mode    => '0755',
    notify  => Service['jmeter'],
  }

  if $::osfamily == 'debian' {
    exec { 'jmeter-update-rc':
      command     => '/usr/sbin/update-rc.d jmeter defaults',
      subscribe   => File['/etc/init.d/jmeter'],
      refreshonly => true,
    }
  }

  service { 'jmeter':
    ensure   => running,
    enable   => true,
    require  => File['/etc/init.d/jmeter'],
    provider => $jmeter::params::service_provider,
  }
}
