module Messaging
  class Message < ApplicationRecord

    self.table_name = "messages"
    self.event_base_name = self.name

    acts_as_paranoid

    belongs_to :conversation, class_name: @@conversation_class, foreign_key: "conversation_id"
    belongs_to :parent, class_name: @@message_class, foreign_key: "parent_id", optional: true
    belongs_to singular_klass(@@speaker_class), class_name: @@speaker_class, optional: true, foreign_key: "user_id"
    has_many :messages, class_name: @@message_class, foreign_key: "parent_id"
    has_many :reads, -> { where(readable_type: @@message_class) }, class_name: @@receipt_class, foreign_key: "readable_id", dependent: :destroy
    has_many :mentions, dependent: :destroy, class_name: @@mention_class

    scope :actual_message, -> { where(system_message: false) }

    def speaker
      send self.class.singular_klass(@@speaker_class)
    end

  end
end