class FeedsController < ActionController::Base

	def simply_hired
		render_feed "feeds/simply_hired"
	end

	def indeed_fr
		render_feed "feeds/indeed_fr"
	end

	def wanajob
		render_feed "feeds/wanajob"
	end

	def les_offres_emplois_fr
		render_feed "feeds/les_offres_emplois_fr"
	end

	def trovit
		render_feed "feeds/trovit"
	end

	private

	def render_feed feed_name
		@ads = ClassifiedAd.with_published_state.select('classified_ads.*').updated_desc
		render(:template => feed_name, :formats => [:xml], :handlers => :builder, :layout => false)
	end
end