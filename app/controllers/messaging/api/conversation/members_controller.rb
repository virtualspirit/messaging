module Messaging
  module Api
    module Conversation
      class MembersController < BaseController

        fetch_resource_and_collection! do
          model_klass Messaging.config.conversation_member_class
          query_scope do |query|
            query.where(conversation_id: conversation.id)
          end
          got_resource_callback do |resource|
            resource.conversation_id = conversation.id
            resource
          end
        end

        def index
          present records
        end

        def show
          present record
        end

        def create
          if record.save
            present record
          else
            present_error record.messages, 422
          end
        end

        def update
          if record.update permitted_attributes
            present record
          else
            present_error record.messages, 422
          end
        end

        def destroy
          record.destroy
          present record
        end

        def search
        end
    end


    end
  end
end