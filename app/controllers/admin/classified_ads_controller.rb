class Admin::ClassifiedAdsController < AdminController
	def index
		@classified_ads = ClassifiedAd.order(created_at: :desc)
	end

	def show
		@classified_ad = ClassifiedAd.find(params[:id])
	end

	def update
    classified_ad = ClassifiedAd.find_by(id: params[:id])
    if classified_ad
      if params[:workflow_event] == "accept"
        classified_ad.accept!
      elsif params[:workflow_event] == "close"
        classified_ad.close!
      elsif params[:workflow_event] == "suspend"
        classified_ad.suspend!
      elsif params[:workflow_event] == "publish"
        classified_ad.publish!
      elsif params[:workflow_event] == "reject"
        classified_ad.reject!(params[:classified_ad][:reject_reason])
      end
      flash[:notice] = "L'annonce #{classified_ad.id} a maintenant le statut : #{classified_ad.current_state}"
    else
      flash[:alert] = "Annonce introuvable!"
    end
    redirect_to admin_classified_ad_path(classified_ad)
  end
end