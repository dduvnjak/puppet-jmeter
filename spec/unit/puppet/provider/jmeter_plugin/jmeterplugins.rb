require 'puppet'
require 'mocha'

RSpec.configure do |config|
  config.mock_with :mocha
end

provider_class = Puppet::Type.type(:jmeter_plugin).provider(:jmeterplugins)

describe provider_class do
  before :each do
    @resource = Puppet::Type::Jmeter_plugin.new(
      {:name => 'foo'}
    )
    @provider = provider_class.new(@resource)
  end

  it 'should return instances' do
    provider_class.expects(:jmeterplugins).with('status').returns <<-EOT
[foo=3.0]
EOT
    instances = provider_class.instances
    expect(instances.size).to eq(1)
  end

  it 'should call jmeterplugins to create' do
    @provider.expects(:jmeterplugins).with('install', 'foo')
    @provider.create
  end
  it 'should call jmeterplugins to destroy' do
    @provider.expects(:jmeterplugins).with('uninstall', 'foo')
    @provider.destroy
  end

end
