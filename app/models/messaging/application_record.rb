module Messaging
  class ApplicationRecord < ActiveRecord::Base

    self.abstract_class = true

    include Messaging::Concerns::Eventable

    @@conversation_class = Messaging.config.conversation_class
    @@message_class = Messaging.config.message_class
    @@conversation_member_class = Messaging.config.conversation_member_class
    @@speaker_class = Messaging.config.speaker_class
    @@mention_class = Messaging.config.mention_class
    @@receipt_class = Messaging.config.receipt_class

  end
end
