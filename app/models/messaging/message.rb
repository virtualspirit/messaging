module Messaging
  class Message < ApplicationRecord

    self.table_name = "messages"

    acts_as_paranoid

    belongs_to :conversation, class_name: @@conversation_class, foreign_key: "conversation_id"
    belongs_to :parent, class_name: @@message_class, foreign_key: "parent_id", optional: true
    belongs_to @@speaker_class.demodulize.underscore.to_sym, class_name: @@speaker_class, optional: true, foreign_key: "user_id"
    has_many :messages, class_name: @@message_class, foreign_key: "parent_id"
    has_many :reads, -> { where(readable_type: @@message_class) }, class_name: @@receipt_class, foreign_key: "readable_id", dependent: :destroy

    scope :actual_message, -> { where(system_message: false) }
  end
end