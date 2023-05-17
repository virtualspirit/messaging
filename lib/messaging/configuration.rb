require 'messaging'

module Messaging
  module Configuration

    autoload :Events, "messaging/configuration/events"

    mattr_accessor :_api

    mattr_accessor :speaker_class
    @@speaker_class = "User"

    mattr_accessor :conversation_class
    @@conversation_class = "Messaging::Conversation"

    mattr_accessor :message_class
    @@message_class = "Messaging::Message"

    mattr_accessor :conversation_member_class
    @@conversation_member_class = "Messaging::ConversationMember"

    mattr_accessor :read_class
    @@read_class = "Messaging::Read"

    mattr_accessor :events
    @@events = Messaging::Configuration::Events

    def self.setup &block
      block.arity.zero? ? instance_eval(&block) : yield(self)
    end

    def configure_events &block
      @@events.configure &block
    end

  end
end