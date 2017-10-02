require 'beaker-rspec'
require 'beaker/puppet_install_helper'
require 'beaker/module_install_helper'

UNSUPPORTED_PLATFORMS = [].freeze

run_puppet_install_helper
install_module
install_module_dependencies

RSpec.configure do |c|
  # Readable test descriptions
  c.formatter = :documentation
end
