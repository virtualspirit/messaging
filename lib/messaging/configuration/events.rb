module Messaging
  module Configuration
    module Events
      autoload :Delegator, "messaging/configuration/events/delegator"

      mattr_accessor :default_namespace
      @@default_namespace = :messaging

      class << self
        delegate :configure, :instrument, :namespace, :namespace=, to: :delegator

        def delegator
          @delegator ||= Delegator.new
        end

      end
    end
  end
end
