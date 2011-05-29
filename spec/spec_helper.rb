$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'rspec'
require 'polypaperclip'
require 'polypaperclip/railtie'

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

config = YAML::load(IO.read(File.dirname(__FILE__) + '/database.yml'))
ActiveRecord::Base.logger = ActiveSupport::BufferedLogger.new(File.dirname(__FILE__) + "/debug.log")
ActiveRecord::Base.establish_connection(config['test'])

RSpec.configure do |config|
  config.mock_with :mocha
  config.before(:all) do
    ActiveRecord::Base.connection.create_table :pages, :force => true do |table|
      table.string :name, :null => false
    end
    puts "created table"

    ActiveRecord::Base.connection.create_table :attachments, :force => true do |table|
      table.integer :attachable_id, :null => false
      table.string :attachable_type, :null => false
      table.string :attachment_type, :null => false
      table.string :attachment_file_name, :null => false
      table.string :attachment_content_type, :null => false
      table.integer :attachment_file_size, :null => false
      table.datetime :attachment_updated_at, :null => false
    end

    ActiveRecord::Base.extend(Polypaperclip::ClassMethods)

    class Page < ActiveRecord::Base
      validates_presence_of :name
      
      has_attachment :primary_image, 
        :styles => {:large => "300x300", :thumb => "100x100"}
      has_attachment :secondary_image, 
        :styles => {:large => "200x200", :thumb => "50x50"}
    end
    
    Object.const_set(:Rails, stub('Rails', :root => File.dirname(__FILE__), :env => 'test'))
  end
end
