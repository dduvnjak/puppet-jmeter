Puppet::Type.type(:jmeter_plugin).provide(:jmeterplugins) do
  desc <<-DESC
Fetches list of installed plugins and manages installing / uninstalling plugins.
Based loosely on the examples in puppetlabs-rabbitmq.
DESC

  has_command(:jmeterplugins, '/usr/share/jmeter/bin/PluginsManagerCMD.sh')

  def self.plugins
    plugins = {}

    lines = jmeterplugins('status').split(%r{\n})
    raise Puppet::Error, 'Cannot get plugin status' unless lines.last =~ %r{\[.*\]}
    line = lines.last.strip
    line = line.tr('[]', '')
    chunks = line.split(', ')
    chunks.each do |chunk|
      name, version = chunk.split('=')
      plugins[name] = version
    end
    plugins
  end

  def self.instances
    resources = []
    plugins.map do |name, _versions|
      plugin = {
        ensure: :present,
        name: name
      }
      resources << new(plugin) if plugin[:name]
    end
    resources
  end

  def self.prefetch(resources)
    plugins = instances
    resources.keys.each do |name|
      if (provider = plugins.find { |plugin| plugin.name == name })
        resources[name].provider = provider
      end
    end
  end

  def create
    jmeterplugins('install', resource[:name])
    @property_hash[:ensure] = :present
  end

  def destroy
    jmeterplugins('uninstall', resource[:name])
    @property_hash[:ensure] = :absent
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  # may need to flush also
end
