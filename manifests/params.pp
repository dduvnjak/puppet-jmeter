# jmeter::params
#
# @summary This class contains OS-specific parameters for jmeter
class jmeter::params {

  case $facts['os']['family'] {
    'Debian': {
      $init_template = 'jmeter/jmeter-init.erb'
      if $facts['os']['name'] == 'Ubuntu' and $facts['os']['release']['full'] == '16.04' {
        $java_version     = '8'
        $jmeter_version   = '3.3'
        $service_provider = 'systemd'
      } else {
        $java_version     = '7'
        $jmeter_version   = '2.9'
        $service_provider = 'debian'
      }
      $jdk_pkg       = "openjdk-${java_version}-jre-headless"
    }
    'RedHat': {
      $init_template = 'jmeter/jmeter-init.redhat.erb'
      if versioncmp($facts['os']['release']['major'], '7') >= 0  {
        $jmeter_version   = '3.3'
        $service_provider = 'systemd'
        $java_version     = '8'
      } else {
        $java_version     = '7'
        $jmeter_version   = '2.9'
        $service_provider = 'redhat'
      }
      $jdk_pkg       = "java-1.${java_version}.0-openjdk"
    }
    default: {
      fail("Module ${module_name} is not supported on ${facts['os']['name']}")
    }
  }

  if $jmeter_version == '2.9' {
    $jmeter_checksum = '0f62c5173fc0bd46f4fe4e850ca8906e612fdaf9'
  } elsif $jmeter_version == '3.3' {
    $jmeter_checksum = 'aa08f999dbc89f171c78556ed5e93379c8b53b1d'
  }
}
