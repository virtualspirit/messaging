begin; require 'pagy';          rescue LoadError; end
begin; require 'kaminari';      rescue LoadError; end
begin; require 'will_paginate'; rescue LoadError; end

unless defined?(Pagy) || defined?(Kaminari) || defined?(WillPaginate::CollectionMethods)
  Kernel.warn <<-WARNING.gsub(/^\s{4}/, '')
    Warning: messaging api relies on either Pagy, Kaminari, or WillPaginate.
    Please install a paginator by adding one of the following to your Gemfile:

    gem 'pagy'
    gem 'kaminari'
    gem 'will_paginate'
  WARNING
end