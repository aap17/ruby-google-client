class Inappuser < ApplicationRecord
has_many :consumables
has_many :subscriptions

	def self.authOk(user,password)
		#hash=Digest::MD5.hexdigest(password)
		return false if ((user.blank?)||(password.blank?))
		hash=password
		account=Inappuser.where(:email=>user)
		if account.blank?
			newUser = Inappuser.new
			newUser.email=user
			newUser.password=password
			newUser.save
			true
		elsif account.first.password==hash
			true
		else
			false
		end
	end

end
