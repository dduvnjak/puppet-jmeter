# @api private
# jmeter::server
#
# @summary This class configures the server component of JMeter.
#
class jmeter::server {

  assert_private()

  $jmeter_user      = $jmeter::jmeter_user
  $jmeter_group     = $jmeter::jmeter_group

  user { $jmeter_user:
    gid => $jmeter_group,
  }
  group { $jmeter_group:
    ensure => present,
  }

  file { '/var/log/jmeter':
    ensure => directory,
    mode   => '0750',
    owner  => $jmeter_user,
    group  => $jmeter_group,
  }
}
