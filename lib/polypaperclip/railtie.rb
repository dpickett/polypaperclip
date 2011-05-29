require "paperclip/railtie"

module Polypaperclip
  require 'rails'

  class Railtie < Rails::Railtie
    initializer 'polypaperclip.insert_into_active_record' do
      ActiveSupport.on_load :active_record do
        ActiveRecord::Base.extend(Polypaperclip::ClassMethods)
      end
    end
    
    generators do
      require "generators/migration_generator"
    end
  end
end

