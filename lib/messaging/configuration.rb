module Messaging
  module Configuration

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

    def self.setup &block
      yield self
    end

  end
end