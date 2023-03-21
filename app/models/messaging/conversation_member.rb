module Messaging
  class ConversationMember < ApplicationRecord

    self.table_name = "conversation_members"

    belongs_to :updated_by, class_name: Messaging.config.speaker_class, foreign_key: "last_updated_by_id", optional: true
    belongs_to :last_message, class_name: Messaging.config.message_class, foreign_key: "last_message_id", optional: true
    has_many :conversation_members, dependent: :destroy, class_name: Messaging.config.conversation_member_class
    has_many :conversation_members_with_deleted, -> { with_deleted }, class_name: Messaging.config.conversation_member_class
    has_many :messages, dependent: :destroy, class_name: Messaging.config.message_class
    has_many Messaging.speaker_class.demodulize.underscore.pluralize.to_sym, through: :conversation_members
    has_one :recent_message, -> { where("system_message = false").order('created_at DESC')  }, class_name: Messaging.config.message_class



  end
end