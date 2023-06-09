require 'messaging/configuration/callbacks'

module Messaging
  module Configuration
    module Api

      mattr_accessor :authenticate
      @@authenticate = -> { nil }

      class << self

        def setup &block
          block.arity.zero? ? instance_eval(&block) : yield(self)
        end

        def authenticate! &block
          @@authenticate = block
        end

        def authenticate! &block
          @@authenticate = block
        end

        def draw_callbacks &block
          callback_set.draw_callbacks(&block)
        end

      end

      module Pagination

        class << self
          def configure
            yield config
          end

          def config
            @config ||= Configuration.new
          end

          def setup
            configure
          end

          alias :configuration :config
        end

        class Configuration
          attr_accessor :per_page_count

          attr_accessor :total

          attr_accessor :per_page

          attr_accessor :page

          attr_accessor :include_total

          attr_accessor :base_url

          attr_accessor :response_formats

          def configure(&block)
            yield self
          end

          def initialize
            @per_page_count = 50
            @total    = 'Total'
            @per_page = 'Per-Page'
            @page     = nil
            @include_total   = true
            @base_url   = nil
            @response_formats = [:json, :xml]
          end

          ['page', 'per_page'].each do |param_name|
            method_name = "#{param_name}_param"
            instance_variable_name = "@#{method_name}"

            define_method method_name do |params = nil, &block|
              if block.is_a?(Proc)
                instance_variable_set(instance_variable_name, block)
                return
              end

              if instance_variable_get(instance_variable_name).nil?
                instance_variable_set(instance_variable_name, (lambda { |p| p[param_name.to_sym] }))
              end

              instance_variable_get(instance_variable_name).call(params)
            end

            define_method "#{method_name}=" do |param|
              if param.is_a?(Symbol) || param.is_a?(String)
                instance_variable_set(instance_variable_name, (lambda { |params| params[param] }))
              else
                raise ArgumentError, "Cannot set page_param option"
              end
            end
          end

          def paginator
            if instance_variable_defined? :@paginator
              @paginator
            else
              set_paginator
            end
          end

          def paginator=(paginator)
            case paginator.to_sym
            when :pagy
              use_pagy
            when :kaminari
              use_kaminari
            when :will_paginate
              use_will_paginate
            else
              raise StandardError, "Unknown paginator: #{paginator}"
            end
          end

          private

          def set_paginator
            conditions = [defined?(Pagy), defined?(Kaminari), defined?(WillPaginate::CollectionMethods)]
            if conditions.compact.size > 1
              Kernel.warn <<-WARNING
              Warning: messaging relies on Pagy, Kaminari, or WillPaginate, but more than
              one are currently active. If possible, you should remove one or the other. If
              you can't, you _must_ configure messaging on your own. For example:

              Messaging.config.api.configure do |config|
                config.paginator = :kaminari
              end

              You should also configure Kaminari to use a different `per_page` method name as
              using these gems together causes a conflict; some information can be found at
              https://github.com/activeadmin/activeadmin/wiki/How-to-work-with-will_paginate

              Kaminari.configure do |config|
                config.page_method_name = :per_page_kaminari
              end

              WARNING
            elsif defined?(Pagy)
              use_pagy
            elsif defined?(Kaminari)
              use_kaminari
            elsif defined?(WillPaginate::CollectionMethods)
              use_will_paginate
            end
          end

          def use_pagy
            @paginator = :pagy
          end

          def use_kaminari
            require 'kaminari/models/array_extension'
            @paginator = :kaminari
          end

          def use_will_paginate
            WillPaginate::CollectionMethods.module_eval do
              def first_page?() !previous_page end
              def last_page?() !next_page end
            end

            @paginator = :will_paginate
          end
        end

      end

      mattr_accessor :pagination
      @@pagination = Pagination

      class ApiCallbackSet < Messaging::Configuration::Callbacks::CallbackSet

        CALLBACKS = ['prepend_before_action', 'before_action', 'around_action', 'after_action', 'model_klass', 'resource_identifier', 'resource_finder_key', 'query_scope', 'query_includes', 'got_resource_callback', 'presenter', 'should_paginate']

        def self.draw_callbacks(constraints = {base: "Messaging::Api"}, &block)
          super constraints, &block
        end

        def self.callback_class
          ApiCallback
        end

      end

      class ApiCallback < Messaging::Configuration::Callbacks::Callback

        def initialize(name, _namespace: [], **_options, &_block)
          super
          @class = "#{@class}_controller"
        end

        def call context
          block = instance_variable_get("@block")
          resourceful_params = context.resourceful_params
          if resourceful_params.keys.include?(name.to_sym)
            value = context.send(name)
            if value.is_a?(Proc)
              if options[:override] == true
                value = block
              else
                if value.is_a?(Messaging::Concerns::Resourceful::Blocks)
                  value.blocks << block
                else
                  value = Messaging::Concerns::Resourceful::Blocks.new([value, block])
                end
              end
            else
              value = block
            end
            context.set_resource_param(name, value)
          else
            context.send name, &block
          end
        end

        def default_class
          "base_controller"
        end

      end

      mattr_accessor :callback_set
      @@callback_set = ApiCallbackSet

    end
  end
end