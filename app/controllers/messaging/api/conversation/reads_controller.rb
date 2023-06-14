module Messaging
  module Api
    module Conversation
      class ReadsController < BaseController

        fetch_resources! do
          model_klass Messaging.config.message_class
          resource_actions []
          resource_identifier :timetoken
          query_scope do |query|

          end
        end

        def update
          if model_klass_constant.action_by_timetoken(_identifier, current_speaker.id, conversation, :read)
            render json: :ok
          else
            present_error record.messages, 422
          end
        end

      end
    end
  end
end