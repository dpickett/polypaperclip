module Polypaperclip
  class Attachment < Paperclip::Attachment
    
    def self.default_options
      #Credit http://www.jonathanspies.com/posts/6-Using-yaml-to-configure-default-options-for-Paperclip
      return @default_options if @default_options

      @default_options = {
        :url                   => "/system/:attachment/:id/:style/:filename",
        :path                  => ":rails_root/public:url",
        :styles                => {},
        :only_process          => [],
        :processors            => [:thumbnail],
        :convert_options       => {},
        :default_url           => "/:attachment/:style/missing.png",
        :default_style         => :original,
        :storage               => :filesystem,
        :use_timestamp         => true,
        :use_default_time_zone => true,
        :hash_digest           => "SHA1",
        :hash_data             => ":class/:attachment/:id/:style/:updated_at",
        :preserve_files        => false
      }

      if defined?(RAILS_ROOT) and File.exists?("#{RAILS_ROOT}/config/paperclip.yml")
        @default_options.merge!(YAML.load_file("#{RAILS_ROOT}/config/paperclip.yml")[RAILS_ENV].symbolize_keys) rescue nil
      end
    end
    
    def initialize(name, instance, options = {})
      super
      
      #retain the actual object in the attachment instance
      @poly_instance = instance
      @poly_name = name

      #cheat instance to reflect the polymorphic attachment
      #this sort of tricks paperclip in order for it to the right things
      @instance = instance.send("#{name}_attachment")
      @name = "attachment"
    end
    
    def assign(uploaded_file)
      build_instance if @instance.nil? #we want to replace
      super
    end
    
    protected
    def build_instance
      @instance ||= @poly_instance.send("build_#{@poly_name}_attachment")
      @instance.attachment_type = @poly_name.to_s
      @instance.attachable = @poly_instance
      @instance
    end

  end
end
