module Messaging
  class Message < ApplicationRecord

    self.table_name = "messages"

    acts_as_paranoid

    # ATTACHMENT = ["image", "video", "audio", "file"]
    # RELATIONS = ["logbook", "poll", "task", "notes", "map", "link", "contact", "meeting", "event"]
    # TEXT = ["reply", "acknowledge", "priority", "text", "callback"]
    # MESSAGE_TYPE = RELATIONS + ATTACHMENT + TEXT

    # MESSAGE_TYPE.each do |method|
    #   define_method "is_#{method}?" do
    #     type_of_message.eql?(method)
    #   end
    #   scope "scope_#{method}", -> { where(type_of_message: method) }
    # end

    scope :actual_message, -> { where(system_message: false) }

    belongs_to :conversation, class_name: Messaging.config.conversation_class
    belongs_to :parent, class_name: Messaging.config.message_class, foreign_key: "parent_id", optional: true
    belongs_to Messaging.config.speaker_class.demodulize.underscore.to_sym, class_name: Messaging.config.speaker_class, optional: true
    has_many :messages, class_name: Messaging.config.message_class, foreign_key: "parent_id"
    has_many :reads, -> { where(readable_type: Messaging.config.message_class) }, class_name: Messaging.config.read_class, foreign_key: "readable_id", dependent: :destroy

  end
end