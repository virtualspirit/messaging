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


  class << self
    delegate :speaker_class, :speaker_class=, :conversation_class, :conversation_class=, :conversation_member_class, :conversation_member_class=, :message_class, :message_class=, :mention_class, :mention_class=, :receipt_class, :receipt_class=, to: :config

    def config
      @@configuration
    end


    def setup &block
      block.arity.zero? ? config.instance_eval(&block) : yield(config)
    end
  end

end


require 'messaging/hooks'