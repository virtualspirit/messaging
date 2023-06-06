module Messaging
  module Api
    class BaseController < ActionController::API

      include Messaging::Concerns::Authenticate
      include Messaging::Concerns::Resourceful
      include Messaging::Configuration::Callbacks::Attacher

      self.callback_set = Messaging::Configuration::Api::ApiCallbackSet

    end
  end
end