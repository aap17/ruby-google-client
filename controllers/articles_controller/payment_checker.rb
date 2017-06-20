class ArticlesController
class PaymentChecker

	def authUser(userHash, articleId, tokenHash)

		if ( (Inappuser.authOk(userHash["user"],userHash["password"])) && (!articleId.blank?) )

			if isAlreadyBought(userHash["user"], articleId)
				# "already_bought"
				return true
			elsif tokenHash.blank?
				#"token_empty"
				return false
			
			elsif buyItem(userHash["user"],articleId,tokenHash["packageName"],tokenHash["productId"], tokenHash["purchaseToken"])
				#"item_bought"
				return true
			else
				#"token error"
				return false
			end
		else
			#"password error"
			return false
		end

	end

private

	def isAlreadyBought(user, articleId)

		(Subscription.new.isAlreadySubscribed(user)) || (Consumable.new.isAlreadyBought(user, articleId))
	end


	def buyItem(user,articleId, packageName, productId, purchaseToken)

		status = false

		case getTokenType(productId)
		when 1
				status = subscribeUser(user, packageName, productId, purchaseToken)
				return status
		when 2
				status = consumeToken(user, articleId, packageName, productId, purchaseToken)
				return  status
		end
	end


	def subscribeUser(user, packageName, productId, purchaseToken)
		
		Subscription.new.subscribeUser(user, packageName, productId, purchaseToken)
	end


	def getTokenType(productId)
		
		if productId == "single_article"
			return 2
		elsif productId == "sub_month"
			return 1
		end
	end


	def consumeToken(user, articleId, packageName, productId, purchaseToken)
		
		return Consumable.new.consumeToken(user, articleId, packageName, productId, purchaseToken)
	end

end
end