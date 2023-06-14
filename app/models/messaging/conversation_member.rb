module Messaging
  class ConversationMember < ApplicationRecord

    self.table_name = "conversation_members"

    acts_as_paranoid

    belongs_to :conversation, counter_cache: :total_participants, class_name: @@conversation_class, foreign_key: :conversation_id
    belongs_to singular_klass(@@speaker_class), class_name: @@speaker_class, foreign_key: "user_id"
    belongs_to :all_user, -> { with_deleted }, optional: true, class_name: @@speaker_class, foreign_key: "user_id"

    has_one :last_message, through: :conversation
    has_one :last_updated_by, through: :conversation

    def speaker
      send self.class.singular_klass(@@speaker_class)
    end

  end
end