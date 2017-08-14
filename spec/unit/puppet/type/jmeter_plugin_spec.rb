require 'spec_helper'
describe Puppet::Type.type(:jmeter_plugin) do
  before :each do
    @plugin = Puppet::Type.type(:jmeter_plugin).new(:name => 'foo')
  end
  it 'should accept a plugin name' do
    @plugin[:name] = 'plugin-name'
    expect(@plugin[:name]).to eq('plugin-name')
  end
  it 'should require a name' do
    expect {
      Puppet::Type.type(:jmeter_plugin).new({})
    }.to raise_error(Puppet::Error, 'Title or name must be provided')
  end
  it 'should not allow invalid names to be specified' do
    expect {
      @plugin[:name] = 'this has a space'
    }.to raise_error(Puppet::Error, /Parameter name failed on Jmeter_plugin/)
  end
end
