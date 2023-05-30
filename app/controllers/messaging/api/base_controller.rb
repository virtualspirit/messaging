module Messaging
  module Api
    class BaseController < ActionController::API

      include Messaging::Concerns::Resourceful

    end
  end
end