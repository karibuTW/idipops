module ApplicationHelper

	def review_rating(star)
		html =  "<span aria-invalid='false' class='rating' readonly='readonly' role='slider' tabindex='0'>"
		5.times do |i|
			html << "<i class='glyphicon fa fa-star #{ i < star ? "on" : "off"}' role='button' tabindex='0' title='#{i + 1}'><span class='sr-only'>(#{ i < star ? '*' : ""})</span></i>"
		end
    html << "</span>"
		html.html_safe
	end

end