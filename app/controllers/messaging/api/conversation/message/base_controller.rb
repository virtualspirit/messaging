module Messaging
  module Api
    module Conversation
      module Message
        class BaseController < Messaging::Api::Conversation::BaseController

          before_action :message

          def message
            @message ||= conversation.messages.find!(params[:message_id])
          end

          def message_class
            Messaging.config.message_class.constantize
          end

        end
      end
    end
  end
end