class Consumable < ApplicationRecord
	belongs_to :inappuser
require 'net/https'

	def isAlreadyBought(user, articleId)
		
		return false if ( (articleId.blank?) || (user.blank?) )

		dbInfo = Consumable.select("*").where(article_id: articleId, inappuser_id: Inappuser.where(email: user))
		
		!(dbInfo.blank?)

	end

	def consumeToken(user, articleId, packageName, productId, token)
		
		return false if ( isTokenFraud(user, token) )
		
		googleToken = Googlescope.new.getToken
		request = "https://www.googleapis.com/androidpublisher/v2/applications/"+packageName+"/purchases/products/"+productId+"/tokens/"+token+"?access_token="+googleToken
		uri = URI(request)
		response = Net::HTTP.get(uri)
		answer = JSON.parse(response)
		

		if !answer["error"].blank?
		
			error_message = answer["error"]["code"].to_s+" : "+answer["error"]["message"]
		
			false
		else
			consumptionState = answer["consumptionState"]

			(consumptionState == 0) ? writeTokenToDB(user, articleId, packageName, productId, token) : false
		end


	end

private

	def writeTokenToDB(user,articleId, packageName, productId, token)

		tokenInfo = Consumable.new
		tokenInfo.inappuser_id = Inappuser.where(email: user).first.id
		tokenInfo.article_id = articleId
	    tokenInfo.packagename = packageName
		tokenInfo.sku_id = productId
		tokenInfo.token = token

		dbInfo = Consumable.select("*").where(sku_id: productId, token: token).limit(1)
		
		if (dbInfo.blank?)
		
			tokenInfo.save
			true
		else
			false
		end
	end


	def isTokenFraud(user, token)

		#some user may use token of another user.
		queryOwnerId = Consumable.select(:inappuser_id).where(token: token)
		ownerId = (queryOwnerId.blank?)? nil : queryOwnerId.first.inappuser_id
		queryUserId = Inappuser.select(:id).where(email: user)
		userId = (queryUserId.blank?) ? nil : queryUserId.first.id
		
		( (ownerId != userId) && (ownerId != nil) )
	end

end