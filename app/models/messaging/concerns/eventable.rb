module Messaging
  module Concerns
    module Eventable

      extend ActiveSupport::Concern

      included do
        [ :after_initialize, :after_find, :after_touch, :before_validation, :after_validation, :before_save, :around_save, :after_save, :before_create, :around_create, :after_create, :before_update, :around_update, :after_update, :before_destroy, :around_destroy, :after_destroy, :after_commit, :after_rollback ].each do  |callback|
          send callback do
            Messaging.config.events.instrument(type: "#{self.class.name.demodulize.downcase}.#{callback}", payload: self)
          end
        end
      end

      def channel
        "Chatting::Channels::#{self.class.name.demodulize}".constantize
      end

    end
  end
end