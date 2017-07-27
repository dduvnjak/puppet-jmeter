require 'spec_helper'

describe 'jmeter' do

  before(:all) do
    @jmeter_version = '3.2'
    @plugin_manager_version = '0.13'
    @cmdrunner_version = '2.0'
  end

  let :facts do
    {
      :osfamily => 'Debian',
      :operatingsystem => 'Ubuntu',
      :operatingsystemrelease => '16.04'
    }
  end

  describe 'with defaults' do
    it { is_expected.to compile.with_all_deps }
    it { is_expected.to contain_class('jmeter') }
    it { is_expected.to contain_class('jmeter::install') }
    it { is_expected.not_to contain_class('jmeter::server') }
  end

  # This is a private class, so easiest to test directly in the class spec.
  context "jmeter::install" do
    let :facts do
      {
        :osfamily => 'Debian',
        :operatingsystem => 'Ubuntu',
        :operatingsystemrelease => '16.04'
      }
    end

    it do
      is_expected.to contain_archive("/tmp/apache-jmeter-#{@jmeter_version}.tgz").with(
        'source' => "http://archive.apache.org/dist/jmeter/binaries/apache-jmeter-#{@jmeter_version}.tgz"
      )
    end
    it do
      is_expected.to contain_file('/usr/share/jmeter').with( 
        ensure: 'link'   
      )
    end
    it do
      is_expected.to contain_package('openjdk-8-jre-headless')
    end

    context "With plugin_manager_install set" do
      let(:params) { { plugin_manager_install: true } }
      it do
        is_expected.to contain_archive("/usr/share/jmeter/lib/ext/jmeter-plugins-manager-#{@plugin_manager_version}.jar").with(
          'source' => "http://search.maven.org/remotecontent?filepath=kg/apc/jmeter-plugins-manager/#{@plugin_manager_version}/jmeter-plugins-manager-#{@plugin_manager_version}.jar",
          'creates' => "/usr/share/jmeter/lib/ext/jmeter-plugins-manager-#{@plugin_manager_version}.jar",
          'cleanup' => :false
        )
      end
      it do
        is_expected.to contain_archive("/usr/share/jmeter/lib/cmdrunner-#{@cmdrunner_version}.jar").with(
          'source'  => "http://search.maven.org/remotecontent?filepath=kg/apc/cmdrunner/#{@cmdrunner_version}/cmdrunner-#{@cmdrunner_version}.jar",
          'creates' => "/usr/share/jmeter/lib/cmdrunner-#{@cmdrunner_version}.jar",
          'cleanup' => :false
        )
      end
      it do
        is_expected.to contain_exec('install_cmdrunner').with(
          'command' => "java -cp /usr/share/jmeter/lib/ext/jmeter-plugins-manager-#{@plugin_manager_version}.jar org.jmeterplugins.repository.PluginManagerCMDInstaller",
          'creates' => '/usr/share/jmeter/bin/PluginsManagerCMD.sh'
        )
      end
    end

    context "With plugins ensured" do
      let(:params) do
        {
          plugins: {
            'foo'    => {'ensure' => 'present'},
            'woozle' => {'ensure' => 'absent'}
          }
        }
      end
      it do
        is_expected.to contain_jmeter_plugin('foo').with(
          'ensure' => 'present',
        )
      end
      it do
        is_expected.to contain_jmeter_plugin('woozle').with(
          'ensure' => 'absent',
        )
      end
    end

    context 'With server enabled' do
      let(:params) { { enable_server: true } }

      it { is_expected.to contain_class('jmeter::server') }
      it do
        is_expected.to contain_service('jmeter').with(
          { 'ensure' => 'running', 'enable' => 'true' }
        )
      end
    end
  end
end
