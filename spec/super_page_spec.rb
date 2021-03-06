require "spec_helper"

describe "SuperPage" do
  subject { SuperPage.new(:name => "some page") }

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
  
  PRIMARY_IMAGE_PATH = File.dirname(__FILE__) + "/fixtures/rails.png"
  def attach_primary_image
    subject.primary_image = File.open(PRIMARY_IMAGE_PATH)
  end
end