require 'spec_helper'

describe "Page" do 
  subject { Page.new(:name => "some page") }

  its(:primary_image) { should_not be_nil }
  its(:primary_image_attachment) { should be_nil }
  
  its(:secondary_image) { should_not be_nil }
  its(:secondary_image_attachment) { should be_nil }
  
  it "does not save an attachment if I did not assign one" do
    subject.save!
    subject.primary_image_attachment.should be_nil
  end
  
  it "saves an attachment when I do save one" do
    attach_primary_image
    subject.save!
    subject.primary_image_attachment.should_not be_nil
  end
  
  it "does not save the attachment if validation fails" do
    subject.name = nil
    attach_primary_image
    subject.save.should be_false
    
    subject.primary_image_attachment.should_not be_persisted
  end
  
  it "sets the content type on the associated attachment" do
    attach_primary_image
    subject.primary_image_attachment.attachment_content_type.should_not be_nil
  end
  
  it "sets the file size on the associated attachment" do
    attach_primary_image
    subject.primary_image_attachment.attachment_file_size.should_not be_nil
  end
  
  it "sets the attachment updated at on the associated attachment" do
    attach_primary_image
    subject.primary_image_attachment.attachment_updated_at.should_not be_nil
  end
  
  PRIMARY_IMAGE_PATH = File.dirname(__FILE__) + "/fixtures/rails.png"
  def attach_primary_image
    subject.primary_image = File.open(PRIMARY_IMAGE_PATH)
  end
end
