xml.instruct!
xml.trovit do
	@ads.each do |ad|
		xml.ad do
			xml.title do
				xml.cdata! ad.title
			end
			xml.date do
				xml.cdata! ad.created_at.strftime("%Y/%m/%d")
			end
			xml.id do
				xml.cdata! ad.id.to_s
			end
			xml.url do
				xml.cdata! "#{root_url}annonce-publique/#{ad.id}"
			end
			xml.city do
				xml.cdata! ad.place.place_name
			end
			xml.postcode do
				xml.cdata! ad.place.postal_code
			end
			xml.region do
				xml.cdata! ad.place.admin_name2
			end
			xml.content do
				xml.cdata! ad.description
			end
			xml.category do
				xml.cdata! ad.professions.first.name
			end
		end
	end
end