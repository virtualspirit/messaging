module Messaging
  module Concerns
    module Resourceful

      extend ActiveSupport::Concern
      include Pagination

      included do

        class_attribute :resourceful_params_
        self.resourceful_params_ = {}

        rescue_from ActiveRecord::RecordNotFound do |e|
          present_error "Record not found", 404
        end

      end

      module ClassMethods


        def resourceful_params key=nil
          if self.resourceful_params_[self.to_s].blank?
            self.resourceful_params_[self.to_s] = {
              model_klass: nil,
              resource_identifier: nil,
              resource_finder_key: nil,
              query_scope: nil,
              query_includes: nil,
              got_resource_callback: nil,
              resource_actions: [ :show, :new, :create, :edit, :update, :destroy ],
              resources_actions: [ :index ],
              resource_params_attributes: [],
              presenter: -> (data) {  data.as_json  }
            }
          end
          if(key)
            return self.resourceful_params_[self.to_s][key]
          else
            return self.resourceful_params_[self.to_s]
          end
        end

        def resourceful_params_merge! opts = {}
          current_opts = resourceful_params
          current_opts = current_opts.merge!(opts)
          self.resourceful_params_[self.to_s] = current_opts
        end

        def set_resource_param key, value
          self.resourceful_params_[self.to_s][key] = value
        end

        def fetch_resource_and_collection!(args = {}, &block)
          fetch_resource! args, &block
          fetch_resources! args, &block
        end

        def fetch_resource!(args = {}, &block)
          resourceful_params.merge!(args)
          yield if block_given?
          prepend_before_action :fetch_resource, only: resource_actions
        end

        def fetch_resources!(args = {}, &block)
          resourceful_params.merge!(resourceful_params)
          yield if block_given?
          prepend_before_action :fetch_resources, only: resources_actions
        end

        def attr_accessor_name
          self.to_s.demodulize.singularize.camelcase
        end

        def model_klass(klass = nil)
          if klass.nil?
            klass = self.resourceful_params[:model_klass]
            if klass.blank?
              klass= self.to_s.demodulize.singularize.camelcase
              set_resource_param :model_klass, klass
            end
            klass
          else
            set_resource_param :model_klass, klass
            klass
          end
        end

        def class_exists?(klass)
          klass = Module.const_get(klass)
          klass.is_a?(Class) && klass < ActiveRecord::Base
        rescue NameError
          false
        end

        def query_scope(query = nil, &block)
          if query.blank? && !block_given?
            resourceful_params(:query_scope)
          else
            if block_given?
              set_resource_param :query_scope, block
            else
              set_resource_param :query_scope, query
            end
          end
        end

        def query_includes(includes = nil, &block)
          if includes.nil? && !block_given?
            resourceful_params(:includes)
          else
            if block_given?
              set_resource_param(:query_includes, block)
            else
              set_resource_param(:query_includes, includes)
            end
          end
        end

        def resource_identifier(identifier = nil, &block)
          if identifier.blank? && !block_given?
            identifier = resourceful_params(:resource_identifier)
            identifier
          else
            if block_given?
              set_resource_param(:resource_identifier, block)
            else
              set_resource_param(:resource_identifier, identifier)
            end
          end
        end

        def resource_finder_key(key = nil, &block)
          if key.blank? && !block_given?
            key = resourceful_params(:resource_finder_key)
            key
          else
            if block_given?
              set_resource_param(:resource_finder_key, block)
            else
              set_resource_param(:resource_finder_key, identifier)
            end
          end
        end

        def resource_identifier_and_finder_key identifier
          resource_identifier identifier
          resource_finder_key identifier
        end

        def got_resource_callback proc = nil, &block
          if proc.blank? && !block_given?
            self.resourceful_params[:got_resource_callback]
          else
            if block_given?
              set_resource_param :got_resource_callback, block
            else
              set_resource_param :got_resource_callback, proc
            end
          end
        end

        def resource_actions actions = nil, &block
          if (actions.blank? && !actions.is_a?(Array)) && !block_given?
            actions = resourceful_params(:resource_actions)
            actions.respond_to?(:call) ? actions.call : actions
          else
            if block_given?
              set_resource_param(:resource_actions, block)
            else
              set_resource_param(:resource_actions, actions)
            end
          end
        end

        def resources_actions actions = nil, &block
          if (actions.blank? && !actions.is_a?(Array)) && !block_given?
            actions = resourceful_params(:resources_actions)
            actions.respond_to?(:call) ? actions.call : actions
          else
            if block_given?
              set_resource_param(:resources_actions, block)
            else
              set_resource_param(:resources_actions, actions)
            end
          end
        end

        def resource_params_attributes(*attributes, &block)
          if attributes.blank? && !block_given?
            resourceful_params(:resource_params_attributes)
          else
            if block_given?
              set_resource_param(:resource_params_attributes, block)
            else
              set_resource_param(:resource_params_attributes, attributes)
            end
          end
        end

        def should_paginate? pg = nil, &block
          if pg.blank? && !block_given?
            pg = resourceful_params(:should_paginate)
            pg.blank?? false : pg
          else
            if block_given?
              set_resource_param :should_paginate, block
            else
              set_resource_param :should_paginate, pg
            end
          end
        end

        def presenter proc=nil, &block
          if proc.blank? && !block_given?
            self.resourceful_params[:presenter]
          else
            if block_given?
              set_resource_param :presenter, block
            else
              set_resource_param :presenter, proc
            end
          end
        end

      end

      def fetch_resource
        return unless @_resource.nil?
        @_resource = _get_resource
        instance_variable_set("@#{self.class.attr_accessor_name}", @_resource)
      end

      def fetch_resources
        return unless @_resources.nil?
        should_paginate = self.class.should_paginate?
        if should_paginate.is_a?(Proc)
          should_paginate = instance_exec(&should_paginate)
        end
        #@_resources = should_paginate ? paginate(_get_resources) : _get_resources
        @_resources = _get_resources
        instance_variable_set("@#{self.class.attr_accessor_name.pluralize}", @_resources)
      end

      def _get_resource
        got_resource = _identifier_param_present? ? _existing_resource : _new_resource
        got_resource = _existing_resource
        if got_resource_callback = self.class.got_resource_callback
          instance_exec(got_resource, &got_resource_callback)
        end
        got_resource
      end

      def _get_resources
        _query
      end

      def _identifier_param_present?
        identifier = _resource_identifier
        if identifier.respond_to?(:call)
          identifier = instance_exec(&identifier)
        end
        params[identifier.to_sym].present?
      end

      def _model_klass
        model_klass = self.class.model_klass
        if model_klass.is_a?(Proc)
          model_klass = instance_exec(&model_klass)
        end
        model_klass
      end

      def model_klass_constant
        return @_model_klass if @_model_klass
        klass = _model_klass
        if self.class.class_exists?(klass)
          klass.constantize
        else
          klass.constantize
        end
      rescue
        raise { ActiveRecord::RecordNotFound }
      end

      def _resource_identifier
        identifier = self.class.resource_identifier
        if identifier.is_a?(Proc)
          identifier = instance_exec &identifier
        end
        if identifier.blank?
          identifier = model_klass_constant.primary_key
        end
        identifier
      end

      def _resource_finder_key
        key = self.class.resource_finder_key
        if key.is_a?(Proc)
          key = instance_exec &key
        end
        if key.blank?
          key = model_klass_constant.primary_key
        end
        key
      end

      def _query
        query = self.class.query_scope
        if query.respond_to?(:call)
          model = _apply_query_includes(model_klass_constant)
          query = instance_exec(model, &query)
        else
          query = _apply_query_includes(model_klass_constant)
          query = query.where.not id: nil
        end
        if(params[:order_by])
          query = query.order params[:order_by]
        end
        query
      end

      def _apply_query_includes query
        unless self.class.query_includes.blank?
          includes = self.class.query_includes
          if includes.is_a?(Array)
            query = query.includes(*self.class.query_includes)
          else
            query = query.includes(self.class.query_includes)
          end
        end
        query
      end

      def _identifier
        id = _resource_identifier
        id = id.is_a?(String)? id.to_sym : id
        if id.is_a? Symbol
          finder_key = _resource_finder_key
          par = { "#{finder_key}": params[id] }
        elsif id.is_a? Array
          Hash[id.map { |i| [i, params[i]] }]
        else
          {}
        end
      end

      def _new_resource
        model_klass_constant.new _resource_params
      end

      def permitted_attributes
        _resource_params
      end

      def _resource_params
        attributes = {}
        permitted_attributes = self.class.resource_params_attributes
        if permitted_attributes.is_a?(Proc)
          permitted_attributes = instance_exec(&permitted_attributes)
        end
        return attributes if permitted_attributes.blank?
        if params[self.class.attr_accessor_name.to_sym].present?
          attributes = params.require(self.class.attr_accessor_name.to_sym).permit(permitted_attributes)
        else
          attributes = params.permit(permitted_attributes)
        end
        attributes
      end

      def _existing_resource
        resource = _query.send('find_by!', _identifier)
        resource
      end

      def resource
        instance_variable_get("@#{self.class.attr_accessor_name}")
      end

      def with_resource &block
        fetch_resource if resource.nil?
        yield if resource.present?
      end

      def present_error message = "Error", status = 500
        render json: { message: message }, status: status
      end

      def present data, status = 200
        render json: presenter(data), status: status
      end

      def presenter data
        options = {}
        if data.is_a?(ActiveRecord::Relation)
          if self.class.should_paginate?
            data = paginate(data)
            options[:meta] = pagination_info
          end
        end
        _presenter = self.presenter
        options[:data] = _presenter.is_a?(Proc) ? instance_exec(data, &_presenter) : data.as_json
        options
      end

      def pagination_info
        hash = {}
        if headers
          config = Messaging.api.pagination.config
          hash[config.per_page] = headers[config.per_page].to_i
          hash[config.page] = headers[config.page].to_i if config.page
          if config.include_total
            hash[config.total] = headers[config.total].to_i
            if hash[config.per_page].to_i > 0
              hash["Total-Pages"] = (hash[config.total].to_f / hash[config.per_page]).ceil
              if hash[config.page]
                hash["Last-Page"] = hash[config.page] >= hash["Total-Pages"]
              end
            end
          end
          hash
        end
      end

    end
  end
end