class Googlescope < ApplicationRecord

	def getToken
	      scopeType = "inapp"
	    
	      googleScope = selectToken(scopeType)
	    
	      if googleScope.blank?

		    googleScope = insertToken(scopeType)
		    googleScope.token

	      elsif !isTokenValid(googleScope)

		    googleScope = updateToken(scopeType)
		    googleScope.token

	      else
		
		    googleScope.first.token
	    
	      end
	      
	end



	def getForceRefreshedToken

		scopeType = "inapp"
		googleScope = updateToken(scopeType)
		googleScope.token
	end

private

	def insertToken(scopeType)

		newToken = googleRequest(scopeType)
		newToken.save
		newToken
	end

	def updateToken(scopeType)

		newTokenInfo = googleRequest(scopeType)
		Googlescope.where(scope: scopeType).update_all(token: newTokenInfo.token, valid_till: newTokenInfo.valid_till)
		newTokenInfo
	end

	def selectToken(scopeType)

		Googlescope.select("token", "valid_till").where(scope: scopeType).limit(1)
	end

	def isTokenValid(query)

		time = query.map(&:valid_till).to_s	
		(DateTime.parse(time) > DateTime.now) ? true : false
	end



	def googleRequest(scopeType)

		ENV['GOOGLE_APPLICATION_CREDENTIALS'] = "#{Rails.root}/config/service_account.json"
		
		scope =  ['https://www.googleapis.com/auth/androidpublisher']
		drive = Google::Apis::DriveV2::DriveService.new
		auth_client = Google::Auth.get_application_default(scope).dup
		drive.authorization = auth_client
		token_info = auth_client.fetch_access_token!
		
		googleToken = Googlescope.new
		googleToken.valid_till = DateTime.now + token_info["expires_in"].to_i.seconds
		googleToken.token = token_info["access_token"]	
		googleToken.scope = scopeType
		googleToken
	end

end
