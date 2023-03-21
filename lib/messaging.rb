require "messaging/version"
require "messaging/railtie"
require "messaging/configuration"

require 'paranoia'

module Messaging
  # Your code goes here...

  mattr_accessor :configuration
  @@configuration = Configuration

  def self.config
    @@configuration
  end

end
