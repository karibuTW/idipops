class AdminMailer < ApplicationMailer

	def classified_ad_to_approve_email classified_ad_id
		@classified_ad = ClassifiedAd.find(classified_ad_id)
		@content = convert_linebreaks @classified_ad.description.truncate(250)
  	mail(to: get_admin_emails, subject: "Nouvelle annonce à approuver sur Idipops.com")
	end
	
	def reported_classified_ad_to_review_email classified_ad_id
		@classified_ad = ClassifiedAd.find(classified_ad_id)
		@content = convert_linebreaks @classified_ad.description.truncate(250)
		@reject_reason = translate_reject_reason @classified_ad.reject_reason
  	mail(to: get_admin_emails, subject: "Une annonce a été signalée sur Idipops.com")
	end
	
	def reported_post_to_review_email post_id
		@post = Post.find(post_id)
		@content = convert_linebreaks @post.truncated_description
		@reject_reason = translate_reject_reason @post.reject_reason
  	mail(to: get_admin_emails, subject: "Un post a été signalé sur Idipops.com")
	end

	private

	def get_admin_emails
		admins = User.active.where(admin: true)
		admin_emails = Array.new()
		admins.each do |admin|
			admin_emails << admin.account.account_emails.first.email if admin.account.account_emails.count > 0
		end
		return admin_emails
	end
end