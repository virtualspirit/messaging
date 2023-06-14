module Messaging
  class Read < ApplicationReprd

    self.table_name = "reads"

    belongs_to :readable, polymorphic: true
    belongs_to singular_klass(@@speaker_class), class_name: @@speaker_class, optional: false, foreign_key: "user_id"

    validates_uniqueness_of :user_id, scope: [:readable_id, :readable_type]

    def speaker
      send self.class.singular_klass(@@speaker_class)
    end

  end
end