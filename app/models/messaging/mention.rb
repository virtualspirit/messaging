module Messaging
  class Mention < ApplicationRecord

    self.table_name= 'mentions'
    self.event_base_name = self.name

    belongs_to :mentionable, polymorphic: true, optional: true
    belongs_to singular_klass(@@speaker_class), class_name: @@speaker_class, optional: true, foreign_key: "user_id"
    belongs_to :message, class_name: @@message_class

    validates_uniqueness_of :message_id, scope: [:mentionable_id, :mentionable_type, :mention_to]

    def speaker
      send self.class.singular_klass(@@speaker_class)
    end

  end
end