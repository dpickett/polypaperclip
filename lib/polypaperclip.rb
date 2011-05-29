require "active_support"
require "active_record"
require "paperclip"

require "polypaperclip/attachment"
require "polypaperclip/persisted_attachment"
require "polypaperclip/railtie"

module Polypaperclip
  module ClassMethods
    def polypaperclip_definitions
      read_inheritable_attribute(:polypaperclip_definitions)
    end

    def has_attachment(name, options = {})
      has_one "#{name}_attachment",
        :as => :attachable,
        :dependent => :destroy,
        :class_name => "Polypaperclip::PersistedAttachment"
        
      has_many_attachments_association
      
      after_save :save_attached_files
      before_destroy :destroy_attached_files
      
      write_inheritable_attribute(:polypaperclip_definitions, {}) if polypaperclip_definitions.nil?
      polypaperclip_definitions[name] = {:validations => []}.merge(options)
      
      define_method name do |*args|
        a = paperclip_attachment_for(name)
        (args.length > 0) ? a.to_s(args.first) : a
      end

      define_method "#{name}=" do |file|
        paperclip_attachment_for(name).assign(file)
      end

      define_method "#{name}?" do
        paperclip_attachment_for(name).file?
      end

      validates_each(name) do |record, attr, value|
        attachment = record.paperclip_attachment_for(name)
        attachment.send(:flush_errors)
      end
      
      #sequence is important here - we have to override some paperclip stuff
      include Paperclip::InstanceMethods
      include InstanceMethods
    end

    protected
    def has_many_attachments_association
      unless self.respond_to?(:attachments)
        has_many :attachments,
          :as => :attachable
      end
    end
  end

  module InstanceMethods
    #we override Paperclip's each_attachment so that we proxy through the attachments model
    def each_attachment
      self.class.polypaperclip_definitions.each do |name, definition|
        yield(name, paperclip_attachment_for(name))
      end
    end

    def paperclip_attachment_for(name)
      @_paperclip_attachments ||= {}
      @_paperclip_attachments[name] ||= Polypaperclip::Attachment.new(name, 
        self, 
        self.class.polypaperclip_definitions[name])
    end
  end
end

