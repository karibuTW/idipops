xml.instruct!
xml.jobs do
	@ads.each do |ad|
		xml.job do
			xml.title do
				xml.cdata! ad.title
			end
			xml.tag! "job-board-name", "MyUnéo"
			xml.tag! "job_board_url", root_url
			xml.tag! "job-code", ad.id
			xml.tag! "detail-url", "#{root_url}annonce-publique/#{ad.id}"
			xml.tag! "apply-url", "#{root_url}annonce-publique/#{ad.id}"
			xml.tag! "job-category", ad.professions.first.name
			xml.description do
				xml.summary do
					xml.cdata! ad.description
				end
			end
			xml.tag! "posted-date", ad.created_at.strftime("%Y/%m/%d")
			xml.location do
				xml.city ad.place.place_name
				xml.country ad.place.country_code
				xml.zip ad.place.postal_code
				xml.state ""
			end
			xml.company do
				xml.name "MyUnéo"
			end
		end
	end
end