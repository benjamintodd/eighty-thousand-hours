# at present used only for images in blog posts
class AttachedImage < ActiveRecord::Base
  # paperclip uploads to S3
  has_attached_file :image, {
                      :styles => { :original => "1024x768", :large => "800x800", :medium => "500x500", :small => "200x200>" },
                      :path => "/posts/images/:id/:style/:filename"
  }.merge(PAPERCLIP_STORAGE_OPTIONS)

  validates_attachment_size :image, :less_than => 2.megabytes,
                            :unless => Proc.new {|m| m[:asset].nil?}
  validates_attachment_content_type :upload, :content_type=>['image/jpeg', 'image/png', 'image/gif'],
                                    :unless => Proc.new {|m| m[:image].nil?}
  validate :image_aspect_ratio, unless: "errors.any?"

  belongs_to :post

  def image_aspect_ratio
    dimensions = Paperclip::Geometry.from_file(image.queued_for_write[:original].path)
    ratio = dimensions.width.to_f / dimensions.height.to_f
    if ratio < 1.3
      errors.add(:image,'Image is too tall, please update the aspect ratio and try again')
    end
  end
end
