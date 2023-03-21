module Messaging
  class Conversation < ApplicationRecord

    self.table_name = "conversations"

    has_many :messages, dependent: :destroy, class_name: Messaging.config.message_class
    has_one :recent_message, -> { where("system_message = false").order('created_at DESC')  }, class_name: Messaging.config.message_class

  end
end