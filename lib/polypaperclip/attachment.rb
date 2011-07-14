module Polypaperclip
  class Attachment < Paperclip::Attachment
    
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
