module Messaging
  module Concerns
    module Authenticate

      extend ActiveSupport::Concern

      included do
        prepend_before_action :authenticate!
      end

      def authenticate!
        current_speaker && current_speaker.class.name == Messaging.config.speaker_class ? current_speaker : reject_unauthenticated!
      end

      def current_speaker
        @@current_speaker ||= instance_exec(&Messaging.config.api.authenticate)
      end

      def reject_unauthenticated!
        raise Messaging::Errors::ApiAuthenticationError unless current_speaker
      end

    end
  end
end
