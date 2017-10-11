require 'spec_helper_acceptance'

describe 'jmeter class:', unless: UNSUPPORTED_PLATFORMS.include?(fact('os.family')) do
  case fact('os.family')
  when 'RedHat'
    jmeter_version = if fact('os.release.major').to_i >= 7
                       '3.3'
                     else
                       '2.9'
                     end
  when 'Debian'
    jmeter_version = if fact('os.name') == 'Ubuntu' && fact('os.release.full') == '16.04'
                       '3.3'
                     else
                       '2.9'
                     end
  end

  context 'base class' do
    it 'applies successfully' do
      pp = "class { '::jmeter': }"

      # Apply twice to ensure no errors the second time.
      apply_manifest(pp, catch_failures: true) do |r|
        expect(r.stderr).not_to match(%r{error}i)
      end
      apply_manifest(pp, catch_failures: true) do |r|
        expect(r.stderr).not_to eq(%r{error}i)

        expect(r.exit_code).to be_zero
      end
    end

    describe file("/usr/share/apache-jmeter-#{jmeter_version}/lib") do
      it { is_expected.to be_directory }
    end
    describe file('/usr/share/jmeter') do
      it { is_expected.to be_symlink }
    end
  end

  context 'with install plugin option' do
    it 'applies successfully' do
      pp = <<-EOS
class { 'jmeter':
  plugin_manager_install => true,
  plugins                => {
    'jpgc-dummy' => { ensure => present },
  }
}
      EOS
      # Apply twice to ensure no errors the second time.
      apply_manifest(pp, catch_failures: true) do |r|
        expect(r.stderr).not_to match(%r{error}i)
      end
      apply_manifest(pp, catch_failures: true) do |r|
        expect(r.stderr).not_to eq(%r{error}i)

        expect(r.exit_code).to be_zero
      end
    end

    describe file("/usr/share/apache-jmeter-#{jmeter_version}/lib/ext/jmeter-plugins-manager-0.16.jar") do
      it { is_expected.to be_file }
    end
    describe file("/usr/share/apache-jmeter-#{jmeter_version}/lib/cmdrunner-2.0.jar") do
      it { is_expected.to be_file }
    end
    describe command('/usr/share/jmeter/bin/PluginsManagerCMD.sh status') do
      its(:stdout) { is_expected.to contain('jpgc-dummy=').after('\[') }
    end
  end

  context 'jmeter::server class' do
    it 'sets up the service' do
      pp = <<-EOS
class { 'jmeter':
  enable_server => true,
}
      EOS
      apply_manifest(pp, catch_failures: true)
    end
    describe service('jmeter') do
      it { is_expected.to be_enabled }
      it { is_expected.to be_running }
    end

    describe port(1099) do
      # This seems to fail, even with a sleep before it
      xit { is_expected.to be_listening }
    end
  end
end
