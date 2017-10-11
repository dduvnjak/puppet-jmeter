require 'spec_helper'

describe 'jmeter' do
  let(:plugin_manager_version) { '0.16' }
  let(:cmdrunner_version) { '2.0' }

  context 'on unsupported distributions' do
    let(:facts) do
      {
        os: { name: 'Unsupported', family: 'Unsupported' }
      }
    end

    it 'we fail' do
      expect { catalogue }.to raise_error(Puppet::Error, %r{Module jmeter is not supported on Unsupported})
    end
  end

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      case facts[:os]['family']
      when 'RedHat'
        if facts[:os]['release']['major'].to_i >= 7
          jmeter_version = '3.3'
          java_package   = 'java-1.8.0-openjdk'
        else
          jmeter_version = '2.9'
          java_package   = 'java-1.7.0-openjdk'
        end
      when 'Debian'
        if facts[:os]['name'] == 'Ubuntu' && facts[:os]['release']['full'] == '16.04'
          jmeter_version = '3.3'
          java_package   = 'openjdk-8-jre-headless'
        else
          jmeter_version = '2.9'
          java_package   = 'openjdk-7-jre-headless'
        end
      end

      has_systemd = (
        (facts[:os]['family'] == 'RedHat' && facts[:os]['release']['major'].to_i >= 7) ||
        (facts[:os]['family'] == 'Debian' && facts[:os]['release']['full'] == '16.04')
      )

      describe 'with defaults' do
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('jmeter') }
        it { is_expected.to contain_class('jmeter::install') }
        it { is_expected.not_to contain_class('jmeter::server') }
        it { is_expected.not_to contain_class('jmeter::service') }
      end

      # This is a private class, so easiest to test directly in the class spec.
      context 'jmeter::install' do
        it do
          is_expected.to contain_archive("/tmp/apache-jmeter-#{jmeter_version}.tgz").with(
            'source' => "http://archive.apache.org/dist/jmeter/binaries/apache-jmeter-#{jmeter_version}.tgz"
          )
        end
        it do
          is_expected.to contain_file('/usr/share/jmeter').with(
            ensure: 'link'
          )
        end

        it { is_expected.to contain_package(java_package) }

        context 'With plugin_manager_install set' do
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

        context 'With plugins ensured' do
          let(:params) do
            {
              plugins: {
                'foo'    => { 'ensure' => 'present' },
                'woozle' => { 'ensure' => 'absent' }
              }
            }
          end

          it do
            is_expected.to contain_jmeter_plugin('foo').with(
              'ensure' => 'present'
            )
          end
          it do
            is_expected.to contain_jmeter_plugin('woozle').with(
              'ensure' => 'absent'
            )
          end
        end

        context 'With server enabled' do
          let(:params) { { enable_server: true } }

          it { is_expected.to contain_class('jmeter::server') }
          it { is_expected.to contain_class('jmeter::service') }
          it do
            is_expected.to contain_service('jmeter').with(
              'ensure' => 'running', 'enable' => 'true'
            )
          end
        end

        context 'on systems with systemd', if: has_systemd do
          let(:params) { { enable_server: true } }

          it { is_expected.to contain_file('/etc/systemd/system/jmeter.service') }
          it { is_expected.not_to contain_file('/etc/init.d/jmeter') }

          context 'with explicit bind_ip' do
            let(:params) { { enable_server: true, bind_ip: '10.5.32.9' } }

            it do
              is_expected.to contain_file('/etc/systemd/system/jmeter.service').with_content(
                %r{\s-Djava.rmi.server.hostname=10\.5\.32\.9\s}
              )
            end
          end

          context 'with explicit bind_port' do
            let(:params) { { enable_server: true, bind_port: 8832 } }

            it do
              is_expected.to contain_file('/etc/systemd/system/jmeter.service').with_content(
                %r{\s-Dserver_port=8832\s}
              )
            end
          end
        end

        context 'on systems without systemd', if: !has_systemd do
          let(:params) { { enable_server: true } }

          it { is_expected.to contain_file('/etc/init.d/jmeter') }
          it { is_expected.not_to contain_file('/etc/systemd/system/jmeter.service') }

          context 'with explicit bind_ip' do
            let(:params) { { enable_server: true, bind_ip: '10.5.32.9' } }

            it do
              is_expected.to contain_file('/etc/init.d/jmeter').with_content(
                %r{\s-Djava.rmi.server.hostname=10\.5\.32\.9\s}
              )
            end
          end

          context 'with explicit bind_port' do
            let(:params) { { enable_server: true, bind_port: 8832 } }

            it do
              is_expected.to contain_file('/etc/init.d/jmeter').with_content(
                %r{\s-Dserver_port=8832\s}
              )
            end
          end
        end
      end
    end
  end
end
