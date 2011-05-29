module Polypaperclip
  class PersistedAttachment < ActiveRecord::Base
    include Paperclip::Glue
    
    set_table_name :attachments
    define_paperclip_callbacks :post_process, :attachment_post_process
  end
end
