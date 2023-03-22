module Messaging
  class Read < ApplicationRecord

    self.table_name = "reads"

    belongs_to :readable, polymorphic: true
    belongs_to Messaging.speaker_class.demodulize.underscore.to_sym

    validates_uniqueness_of :user_id, scope: [:readable_id, :readable_type]

  end
end