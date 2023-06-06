require "messaging/version"
require "messaging/railtie"
require 'messaging/engine'
require "messaging/configuration"

require 'paranoia'
require 'options_model'

module Messaging
  # Your code goes here...

  mattr_accessor :configuration
  @@configuration = Configuration

  def self.config
    @@configuration
  end

  def self.setup &block
    block.arity.zero? ? config.instance_eval(&block) : yield(config)
  end

end


require 'messaging/hooks'