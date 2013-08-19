class CareerAdviceRequest
  include ActiveModel::Validations

  validates_presence_of :name, :email

  validates_each :email do |record, attr, value|
    record.errors.add attr, 'not a valid email address' if value !~ /@/
  end

  # to deal with form, you must have an id attribute
  attr_accessor :id, :name, :email, :skype, :background, :thoughts, :questions, :mailing_list, :upload_cv

  def initialize(attributes = {})
    attributes.each do |key, value|
      self.send("#{key}=", value)
    end
    @attributes = attributes
  end

  def read_attribute_for_validation(key)
    @attributes[key]
  end
 
  def to_key
  end

  def save
    if self.valid?
      begin
        CareerAdviceRequestMailer.career_advice_request_email(name,email,skype,background,thoughts,questions,mailing_list,upload_cv).deliver!
      rescue => e
        puts e.message
      ensure
        return true
      end
    end
    return false
  end

  def persisted?
    false
  end
end
