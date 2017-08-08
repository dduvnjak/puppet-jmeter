Puppet::Type.newtype(:jmeter_plugin) do
  @doc = "Manage jmeter plugins."

  ensurable do
    desc 'Ensure that a plugin is installed or absent. Hope to support specifying version in the future'
    defaultto(:present)
    newvalue(:present) do
      provider.create
    end
    newvalue(:absent) do
      provider.destroy
    end
  end

  newparam(:name, :namevar => true) do
    desc "Name of the plugin."
    newvalues(/^\S+$/)
  end

end
