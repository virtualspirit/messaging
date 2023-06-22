module Messaging
  class Conversation < ApplicationRecord

    self.table_name = "conversations"
    self.event_base_name = self.name

    belongs_to :last_updated_by, class_name: @@speaker_class, foreign_key: "last_updated_by_id", optional: true
    belongs_to :last_message, class_name: @@message_class, foreign_key: "last_message_id", optional: true
    has_many :conversation_members, dependent: :destroy, class_name: @@conversation_member_class
    has_many :conversation_members_with_deleted, -> { with_deleted }, class_name: @@conversation_member_class
    has_many plural_klass(@@speaker_class), through: :conversation_members
    has_many :messages, dependent: :destroy, class_name: @@message_class, foreign_key: "conversation_id"
    has_one :recent_message, -> { where("system_message = false").order('created_at DESC')  }, class_name: @@message_class, foreign_key: "conversation_id"

  end
end