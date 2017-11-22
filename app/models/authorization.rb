class Authorization < ActiveRecord::Base
	belongs_to :customer
	validates_presence_of :customer_id, :uid, :provider
	validates_uniqueness_of :uid, :scope => :provider
	def self.from_omniauth(auth)
    	find_by_provider_and_uid(auth["provider"], auth["uid"]) || create_with_omniauth(auth)
	end

	def self.create_with_omniauth(auth)
		create! do |user|
			user.provider = auth["provider"]
			user.uid = auth["uid"]
			#user.name = auth["info"]["name"]
		end
	end
end
