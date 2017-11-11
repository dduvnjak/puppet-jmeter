require 'beaker-rspec'
require 'beaker/puppet_install_helper'
require 'beaker/module_install_helper'

UNSUPPORTED_PLATFORMS = [].freeze

run_puppet_install_helper
install_module
install_module_dependencies

# Additional modules for soft deps
install_module_from_forge('camptocamp-systemd', '>= 1.0.0 < 2.0.0')

RSpec.configure do |c|
  # Readable test descriptions
  c.formatter = :documentation
end
