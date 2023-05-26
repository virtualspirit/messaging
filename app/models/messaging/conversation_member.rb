module Messaging
  class ConversationMember < ApplicationRecord

    self.table_name = "conversation_members"

    belongs_to :conversation, counter_cache: :total_participants, class_name: @@conversation_class, foreign_key: :conversation_id
    belongs_to @@speaker_class.demodulize.singularize.downcase, class_name: @@speaker_class, foreign_key: "user_id"
    belongs_to Messaging.speaker_class.demodulize.underscore.singularize.to_sym, class_name: Messaging.speaker_class
    belongs_to :all_user, -> { with_deleted }, optional: true, class_name: "User", foreign_key: "user_id"

    has_one :last_message, through: :conversation
    has_one :last_updated_by, through: :conversation


  end
end