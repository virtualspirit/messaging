module Messaging
  module Configuration
    module Events
      autoload :Delegator, "messaging/configuration/events/delegator"

      class << self
        delegate :configure, :instrument, :namespace, :namespace=, to: :delegator

        def delegator
          @delegator ||= Delegator.new
        end
      end
    end
  end
end
