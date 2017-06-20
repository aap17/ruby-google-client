class ArticlesController < ApplicationController

		def full_article
			@article = Article.find(params[:id])

			userHash = Hash.new
			userHash["user"] = params[:user]
			userHash["password"] = params[:password]

			tokenHash = Hash.new
			tokenHash["packageName"] = params[:packageName]
			tokenHash["productId"] = params[:productId]
			tokenHash["purchaseToken"] = params[:purchaseToken]

			if PaymentChecker.new.authUser(userHash, params[:id], tokenHash)
				@myArt = Array.new
			        @myArt << {
			                id: @article.id,
			                title: @article.title,
			                brief: @article.brief,
			                text: @article.text
			                }
			    
			    json_response(@myArt)
			end
		end
end
