module Messaging
  module Configuration

    mattr_accessor :_api

    def self.setup &block
      yield self
    end

  end
end