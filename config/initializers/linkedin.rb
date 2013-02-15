LinkedIn::Client.class_eval do
  def get_email
    path = "/people/~/email-address"
    response = get(path)
    response
  end
end