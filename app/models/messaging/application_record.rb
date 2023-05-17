module Messaging
  class ApplicationRecord < ActiveRecord::Base

    self.abstract_class = true

    include Messaging::Concerns::Eventable

  end
end
