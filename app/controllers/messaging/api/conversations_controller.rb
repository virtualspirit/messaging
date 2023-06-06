module Messaging
  module Api
    class ConversationsController < BaseController

      fetch_resource_and_collection! do
        model_klass Messaging.config.conversation_class
      end

      def index
        present @_resources
      end

      def show
      end

      def create
      end

      def update
      end

      def destroy
      end

      def search
      end


    end
  end
end