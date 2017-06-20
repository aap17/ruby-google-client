require 'net/http'
require 'json'

class Subscription < ApplicationRecord
	belongs_to :inappuser


	def isAlreadySubscribed(user)
		case getSubStatus(user)
		when "active"
			return true
		when "expired"
			return refreshSubscriptionInfo(user, nil, nil, nil)
		when "not_checked"
			return refreshSubscriptionInfo(user, nil, nil, nil)
		end
		return false

	end



	def subscribeUser(user, packageName, productId, purchaseToken)
		
		case getSubStatus(user)
		when "unknown"
			return refreshSubscriptionInfo(user, packageName, productId, purchaseToken)
		when "expired"
			return refreshSubscriptionInfo(user, packageName, productId, purchaseToken)
		when "not_checked"
			return refreshSubscriptionInfo(user, packageName, productId, purchaseToken)
		when "active"
			return true
		end

	end

private



	def getSubStatus(user)
		dbInfo = Subscription.select("*").where( :inappuser_id=>Inappuser.where(:email=>user))
		if (dbInfo.blank?)
			"unknown"
		elsif ((dbInfo.first.updated_at.to_date == DateTime.now.to_date) && (dbInfo.first.valid_till.to_date >= DateTime.now.to_date))
			"active"
		elsif (dbInfo.first.updated_at > dbInfo.first.valid_till)
			"expired"
		else 
			"not_checked"
		end
	end



	def refreshSubscriptionInfo(user,packageName,productId, token)
		
		if (packageName == nil || productId == nil || token == nil)			
				dbInfo = Subscription.select("*").where( inappuser_id: Inappuser.where(email: user)).first
				packageName = dbInfo.packagename
				productId = dbInfo.sku_id
				token = dbInfo.token
		elsif isTokenFraud(user, token)
				return false
		end

		googleToken = Googlescope.new.getToken()
		request = "https://www.googleapis.com/androidpublisher/v2/applications/"+packageName+"/purchases/subscriptions/"+productId+"/tokens/"+token+"?access_token="+googleToken
		uri = URI(request)
		response = Net::HTTP.get(uri)
		answer = JSON.parse(response)

		if !answer["error"].blank?
			error_message=answer["error"]["code"].to_s+" : "+answer["error"]["message"]

			false
		else
			unix_date = answer["expiryTimeMillis"]
			valid_till = DateTime.strptime(unix_date, '%Q').to_date
			tokenInfo = Subscription.new
	      	tokenInfo.packagename = packageName
			tokenInfo.sku_id = productId
			tokenInfo.token = token
			tokenInfo.valid_till = valid_till
			tokenInfo.inappuser_id = Inappuser.where(email: user).first.id
			
			dbInfo = Subscription.select("*").where(inappuser_id: Inappuser.where(email: user).first.id)
			(dbInfo.blank?) ? tokenInfo.save :  Subscription.where(inappuser_id: Inappuser.where(email: user).first.id).update_all(token: token, valid_till: tokenInfo.valid_till, updated_at: DateTime.now)

			(valid_till >= DateTime.now.to_date)
		end
	end


	def isTokenFraud(user, token)
		#some user may use token of another user.
		queryOwnerId = Subscription.select(:inappuser_id).where(token: token)
		ownerId = (queryOwnerId.blank?) ? nil : queryOwnerId.first.inappuser_id
		queryUserId = Inappuser.select(:id).where(email: user)
		userId = (queryUserId.blank?) ? nil : queryUserId.first.id

		((ownerId != userId) && (ownerId != nil))
	end




end