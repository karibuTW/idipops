xml.instruct!
xml.offres do
	@ads.each do |ad|
		xml.offre do
			xml.ID do
				xml.cdata! ad.id.to_s
			end
			xml.TITRE do
				xml.cdata! ad.title
			end
			xml.URL do
				xml.cdata! "#{root_url}annonce-publique/#{ad.id}"
			end
			xml.DESCRIPTION do
				xml.cdata! ad.description
			end
			xml.REGION do
				xml.cdata! ad.place.admin_name1
			end
			xml.DEPARTEMENT do
				xml.cdata! ad.place.admin_name2
			end
			xml.CP do
				xml.cdata! ad.place.postal_code
			end
			xml.VILLE do
				xml.cdata! ad.place.place_name
			end
			xml.CONTRAT do
				xml.cdata! ""
			end
			xml.SALAIRE do
				xml.cdata! ""
			end
			xml.COMPANY do
				xml.cdata! ""
			end
			xml.DATE_PARU do
				xml.cdata! ad.created_at.strftime("%Y-%m-%d")
			end
			xml.SITE do
				xml.cdata! "MyUnéo"
			end
		end
	end
end