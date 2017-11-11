require 'puppet'
require 'mocha'

RSpec.configure do |config|
  config.mock_with :mocha
end

provider_class = Puppet::Type.type(:jmeter_plugin).provider(:jmeterplugins)

describe provider_class do
  let(:resource) do
    Puppet::Type::Jmeter_plugin.new(name: 'foo')
  end
  let(:provider) do
    provider_class.new(resource)
  end

  it 'returns instances' do
    provider_class.expects(:jmeterplugins).with('status').returns <<-EOT
INFO    2017-10-11 20:07:17.864 [org.jmet] (): Command is: status
WARN    2017-10-11 20:07:17.963 [org.jmet] (): Found JAR conflict: /usr/share/apache-jmeter-2.9/lib/commons-jexl-2.1.1.jar and /usr/share/apache-jmeter-2.9/lib/commons-jexl-1.1.jar
[foo=3.0, jmeter-ftp=2.9]
EOT
    instances = provider_class.instances
    expect(instances.size).to eq(2)
  end

  it 'errors if the expected output is not found' do
    provider_class.expects(:jmeterplugins).with('status').returns <<-EOT
ERROR: java.lang.IllegalArgumentException: Command parameter is missing
*** Problem's technical details go below ***
Home directory was detected as: /usr/share/apache-jmeter-2.9/lib
Exception in thread "main" java.lang.IllegalArgumentException: Command parameter is missing
	at org.jmeterplugins.repository.PluginManagerCMD.processParams(PluginManagerCMD.java:52)
	at kg.apc.cmdtools.PluginsCMD.processParams(PluginsCMD.java:66)
EOT
    expect do
      provider_class.instances
    end.to raise_error(Puppet::Error, %r{Cannot get plugin status})
  end

  it 'calls jmeterplugins to create' do
    provider.expects(:jmeterplugins).with('install', 'foo')
    provider.create
  end
  it 'calls jmeterplugins to destroy' do
    provider.expects(:jmeterplugins).with('uninstall', 'foo')
    provider.destroy
  end
end
