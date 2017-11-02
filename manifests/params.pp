# jmeter::params
#
# @summary This class contains OS-specific parameters for jmeter
class jmeter::params {

  case $facts['os']['family'] {
    'Debian' : {
      $init_template = 'jmeter/jmeter-init.erb'
      if $facts['os']['name'] == 'Ubuntu' and $facts['os']['release']['full'] == '16.04' {
        $java_version = '8'
        $service_provider = systemd
      } else {
        $java_version = '7'
        $service_provider = debian
      }
      $jdk_pkg       = "openjdk-${java_version}-jre-headless"
    }
    'RedHat' : {

      if versioncmp($facts['os']['release']['major'], '7') >= 0  {
        # TODO: add systemd stuff here
        $service_provider = systemd
        $init_template = 'jmeter/jmeter-init.redhat.erb'
        $java_version  = '8'
      } else {
        $service_provider = redhat
        $init_template = 'jmeter/jmeter-init.redhat.erb'
        $java_version  = '7'
      }

      $jdk_pkg       = "java-1.${java_version}.0-openjdk"

    }
    default: {
      fail("Module ${module_name} is not supported on ${facts['os']['name']}")
    }
  }
}
