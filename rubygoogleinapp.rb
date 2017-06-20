class Rubygoogleinapp < ApplicationRecord
		def getOuthToken

			ENV['GOOGLE_APPLICATION_CREDENTIALS'] = "#{Rails.root}/config/service_account.json"
			
			scope =  ['https://www.googleapis.com/auth/androidpublisher']
			drive = Google::Apis::DriveV2::DriveService.new
			auth_client = Google::Auth.get_application_default(scope).dup
			drive.authorization = auth_client
			token_info = auth_client.fetch_access_token!
	
			token_info["access_token"]	
	
		end

	def isSubscriptionOk(packageName,productId, token)
		
		googleToken = getOuthToken
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
			
			(valid_till >= DateTime.now.to_date)
		end
	end

	def consumeToken(packageName, productId, token)

		googleToken = getOuthToken

		request = "https://www.googleapis.com/androidpublisher/v2/applications/"+packageName+"/purchases/products/"+productId+"/tokens/"+token+"?access_token="+googleToken
		uri = URI(request)
		response = Net::HTTP.get(uri)
		answer = JSON.parse(response)
		

		if !answer["error"].blank?
		
			error_message = answer["error"]["code"].to_s+" : "+answer["error"]["message"]
		
			false
		else
			consumptionState = answer["consumptionState"]

			(consumptionState == 0) ? true : false
		end


	end

end

