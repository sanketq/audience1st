class Identity < OmniAuth::Identity::Models::ActiveRecord
  validates_uniqueness_of :email
  validates_format_of :email, :with => /\A[-a-z0-9_+\.]+\@([-a-z0-9]+\.)+[a-z0-9]{2,4}\z/i
  belongs_to :customer


  def self.from_omniauth(auth)
      find_by_provider_and_uid(auth["provider"], auth["uid"]) || create_with_omniauth(auth)
  end
  require 'securerandom'
  def self.create_with_omniauth(auth)
    puts(auth)
    create! do |user|
      user.provider = auth["provider"]
      user.uid = auth["uid"]
      user.name = auth["info"]["name"]
      # it checks validation twice for some reason and has a problem with email being equal to the email that was validated last time this exact email was checked. So generate a random one, it doesn't really matter
      user.email = SecureRandom.urlsafe_base64.to_s << '@gmail.com'
      user.password = SecureRandom.urlsafe_base64
    end
  end
end
