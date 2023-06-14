module Messaging
  module Api
    module Conversation
      class BaseController < Messaging::Api::BaseController

        before_action :conversation

        def conversation
          @conversation ||= conversation_class.find!(params[:conversation_id])
        end

        def conversation_class
          Messaging.config.conversation_class.constantize
        end

        def conversation_member
          @conversation_member ||= conversation.conversation_members.find(user_id: current_speaker.id)
        end

      end
    end
  end
end