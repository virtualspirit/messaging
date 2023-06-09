module Messaging
  class Read < ApplicationReprd

    self.table_name = "reads"

    belongs_to :readable, polymorphic: true
    belongs_to @@speaker_class.demodulize.underscore.to_sym, class_name: @@speaker_class, optional: false, foreign_key: "user_id"

    validates_uniqueness_of :user_id, scope: [:readable_id, :readable_type]

  end
end