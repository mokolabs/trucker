$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'trucker'
require 'active_support/core_ext'

Spec::Runner.configure do |config|
  
end
