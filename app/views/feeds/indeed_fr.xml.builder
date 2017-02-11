xml.instruct!
xml.source do
	xml.publisher "MyUnéo"
	xml.publisherurl root_url
	@ads.each do |ad|
		xml.job do
			xml.title do
				xml.cdata! ad.title
			end
			xml.date do
				xml.cdata! ad.created_at.strftime("%Y/%m/%d")
			end
			xml.referencenumber do
				xml.cdata! ad.id.to_s
			end
			xml.url do
				xml.cdata! "#{root_url}annonce-publique/#{ad.id}"
			end
			xml.city do
				xml.cdata! ad.place.place_name
			end
			xml.country do
				xml.cdata! ad.place.country_code
			end
			xml.description do
				xml.cdata! ad.description
			end
			xml.category do
				xml.cdata! ad.professions.map(&:name).join(",")
			end
		end
	end
end