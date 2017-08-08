# jmeter::install
#
# @summary This class installs JMeter (and, optionally, the plugin manager), from tarball. It also handles installing plugins.
#
class jmeter::install {

  assert_private()

  # Get rid of trailing slashes, as they mess up the redirect.
  $download_url           = regsubst($::jmeter::download_url, '/$', '')
  $plugin_manager_url     = regsubst($::jmeter::plugin_manager_url, '/$', '')

  $base_dir = '/usr/share'
  $lib_dir  = "${base_dir}/jmeter/lib"
  $ext_dir  = "${lib_dir}/ext"

  if $::jmeter::manage_java {
    ensure_packages($::jmeter::jdk_pkg)
  }

  ensure_packages(['unzip', 'wget'])

  $jmeter_filename = "apache-jmeter-${::jmeter::jmeter_version}"
  archive { "/tmp/${jmeter_filename}.tgz":
    source        => "${download_url}/${jmeter_filename}.tgz",
    extract       => true,
    extract_path  => $base_dir,
    creates       => "${base_dir}/${jmeter_filename}",
    cleanup       => true,
    checksum      => $::jmeter::jmeter_checksum,
    checksum_type => $::jmeter::checksum_type,
  }

  file { "${base_dir}/jmeter":
    ensure  => link,
    target  => "${base_dir}/${jmeter_filename}",
    require => Archive["/tmp/${jmeter_filename}.tgz"],
  }

  # Downloading the plugin sets and extracting is now deprecated in favor of
  # plugin manager. Download it, and then use an exec to install the requested
  # plugins.
  #
  # https://jmeter-plugins.org/wiki/PluginsManagerAutomated/#Plugins-Manager-from-Command-Line
  # has some more details
  # 
  # Between the URLs w/ redirects, the link structure, and the versioning,
  # this section could still be kind of fragile, so overriding these
  # parameters would need to be done carefully, and versions / checksums may
  # need to be kept up-to-date.
  #

  if $::jmeter::plugin_manager_install {

    $plugin_manager_filename = "jmeter-plugins-manager-${::jmeter::plugin_manager_version}.jar"

    archive { "${ext_dir}/${plugin_manager_filename}":
      source        => "${plugin_manager_url}/jmeter-plugins-manager/${::jmeter::plugin_manager_version}/${plugin_manager_filename}",
      creates       => "${ext_dir}/${plugin_manager_filename}",
      require       => File["${base_dir}/jmeter"],
      cleanup       => false,
      checksum      => $::jmeter::plugin_manager_checksum,
      checksum_type => $::jmeter::checksum_type,
    }

    # These next steps are necessary to be able to non-interactively install plugins
    $cmdrunner_filename = "cmdrunner-${::jmeter::cmdrunner_version}.jar"

    archive { "${lib_dir}/${cmdrunner_filename}":
      source        => "${plugin_manager_url}/cmdrunner/${::jmeter::cmdrunner_version}/${cmdrunner_filename}",
      creates       => "${lib_dir}/${cmdrunner_filename}",
      require       => File["${base_dir}/jmeter"],
      cleanup       => false,
      checksum      => $::jmeter::cmdrunner_checksum,
      checksum_type => $::jmeter::checksum_type,
    }

    exec { 'install_cmdrunner':
      command => "java -cp ${ext_dir}/${plugin_manager_filename} org.jmeterplugins.repository.PluginManagerCMDInstaller",
      creates => "${base_dir}/jmeter/bin/PluginsManagerCMD.sh",
      require => Archive["${ext_dir}/${plugin_manager_filename}"],
    }

  }

  if $::jmeter::plugins {
    create_resources(jmeter_plugin, $::jmeter::plugins)
  }
}
