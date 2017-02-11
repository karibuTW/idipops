class CanAccessAdmin
	def self.matches?(request)
	    request.session[:current_account_id].present? and User.where(account_id: request.session[:current_account_id]).first.admin
	end
end