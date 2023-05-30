require 'messaging'

module Messaging
  module Configuration

    autoload :Events, "messaging/configuration/events"
    autoload :Api, "messaging/configuration/api"

    mattr_accessor :_api
    @@_api = Messaging::Configuration::Api

    mattr_accessor :speaker_class
    @@speaker_class = "User"

    mattr_accessor :conversation_class
    @@conversation_class = "Messaging::Conversation"

    mattr_accessor :message_class
    @@message_class = "Messaging::Message"

    mattr_accessor :conversation_member_class
    @@conversation_member_class = "Messaging::ConversationMember"

    mattr_accessor :receipt_class
    @@receipt_class = "Messaging::Read"

    mattr_accessor :mention_class
    @@mention_class = "Messaging::Mention"

    mattr_accessor :events
    @@events = Messaging::Configuration::Events

    def self.setup &block
      block.arity.zero? ? instance_eval(&block) : yield(self)
    end

    def self.configure_events &block
      @@events.configure &block
    end

    def self.api
      @@_api
    end

  end
end