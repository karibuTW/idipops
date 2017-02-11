xml.instruct!
xml.offres do
	@ads.each do |ad|
		xml.offre do
			xml.general do
				xml.intitule do
					xml.cdata! ad.title
				end
				xml.description do
					xml.cdata! ad.description
				end
				xml.job_code ad.id
				xml.posted_date ad.created_at.strftime("%d/%m/%Y")
				xml.site_emploi "MyUnéo"
				xml.url_site root_url
				xml.url_detail "#{root_url}annonce-publique/#{ad.id}"
			end
			xml.localisation do
				xml.commune ad.place.place_name
				xml.cp ad.place.postal_code
				xml.pays ad.place.country_code
			end
			xml.filtre do
				xml.filtre_categorie_emploi ad.professions.map(&:name).join(",")
			end
		end
	end
end