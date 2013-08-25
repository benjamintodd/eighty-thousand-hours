require 'pry'
class CareerAdviceRequest < ActiveRecord::Base

  # to deal with form, you must have an id attribute
  attr_accessible :id, :name, :email, :skype, :background, :thoughts, :questions, :mailing_list, :upload_cv
  attr_accessor :upload_cv

  #include ActiveModel::Validations

  validates_presence_of :name, :email

  validates_each :email do |record, attr, value|
    record.errors.add attr, 'not a valid email address' if value !~ /@/
  end

  after_create :send_email


  #def initialize(attributes = {})
  #  attributes.each do |key, value|
  #    self.send("#{key}=", value)
  #  end
  #  @attributes = attributes
  #end

  #def read_attribute_for_validation(key)
  #  @attributes[key]
  #end
 
  #def to_key
  #end

  def send_email
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

  #def persisted?
  #  false
  #end
end
