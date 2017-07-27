# jmeter
#
# @summary Main class for jmeter module
# 
# @example Declaring the class
#   class { 'jmeter': }
#
# @example Configuring to install plugins
#   class { 'jmeter':
#     jmeter_version         => '3.2',
#     plugin_manager_install => true,
#     plugins                => {
#       'foo' => { ensure => present },
#       'bar' => { ensure => present },
#     }
#    }
#
# @example Enabling server (and jmeter service)
#   class { 'jmeter':
#     enable_server => true,
#     bind_ip       => 10.3.3.6,
#   }
#
# @param bind_ip [String] IP address to bind to. Defaults to '0.0.0.0' (all interfaces). Replaces `jmeter::server::server_ip`
# @param checksum_type [String] Checksum type to use for all download commands that use one. You can set to 'none' to disable this check.
# @param cmdrunner_checksum [String] Checksum for the cmdrunner .jar.
# @param cmdrunner_version [String] Version of cmdrunner to use. This should generally be left as default.
# @param download_url [String] Download URL for Jmeter.
# @param enable_server [Boolean] Whether to enable the server. Replaces the previous method of declaring `class { 'jmeter::server': }`
# @param java_version [String] Java version to install.
# @param jdk_pkg [Boolean] Name for the jdk package.
# @param jmeter_version [String] Sets version of jmeter to install. Note that 3.x requires Java v8.
# @param jmeter_checksum [String] Checksum for the Jmeter binary.
# @param manage_java [Boolean] Whether to ensure that java is installed.
# @param plugin_manager_checksum [String] Checksum for the plugin manager download.
# @param plugin_manager_install [Boolean] Whether or not to install the plugin manager.
# @param plugin_manager_url [String] Download URL for both the plugin manager and command runner. Note, this redirects, and part of the path has the package name appended and is built dynamically in jmeter::install.
# @param plugin_manager_version [String] Sets the version of the plugin manager to install.
# @param plugins [Optional[Hash]] An optional hash of plugins to install via the plugin manager.
class jmeter (
  $enable_server           = false,
  $bind_ip                 = '0.0.0.0',
  $jmeter_version          = '3.2',
  $jmeter_checksum         = '0a4aa15b39bd18e966948cde559dc82360326125',
  $checksum_type           = 'sha1',
  $plugin_manager_install  = false,
  $plugin_manager_version  = '0.13',
  $cmdrunner_version       = '2.0',
  $cmdrunner_checksum      = '06ecaa09961e3d7bab009fed4fd6d34db81fa830',
  $plugins                 = undef,
  $download_url            = 'http://archive.apache.org/dist/jmeter/binaries/',
  $plugin_manager_url      = 'http://search.maven.org/remotecontent?filepath=kg/apc/',
  $plugin_manager_checksum = 'e80c003adb58cf152f861fdce398e0e76c3593da',
  $java_version            = $jmeter::params::java_version,
  $manage_java             = true,
  $jdk_pkg                 = $jmeter::params::jdk_pkg
) inherits jmeter::params {

  Exec { path => '/bin:/usr/bin:/usr/sbin' }

  validate_legacy('Optional[Boolean]', 'validate_bool', $plugin_manager_install)
  # It looks like archive module already validates the URI itself
  validate_legacy('Optional[String]', 'validate_re', $download_url, ['.'])
  validate_legacy('Optional[String]', 'validate_re', $plugin_manager_url, ['.'])
  validate_legacy('Optional[Boolean]', 'validate_bool', $manage_java)
  validate_legacy('Optional[Boolean]', 'validate_bool', $enable_server)

  contain ::jmeter::install

  if $enable_server {
    contain ::jmeter::server

    Class['::jmeter::install']
    ~> Class['::jmeter::server']
  }

}
