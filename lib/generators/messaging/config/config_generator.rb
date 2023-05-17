module Messaging
  module Generators
    class ConfigGenerator < Rails::Generators::Base
      source_root File.join(__dir__, "templates")

      def generate_config
        copy_file "messaging.rb", "config/initializers/messaging.rb"
      end
    end
  end
end