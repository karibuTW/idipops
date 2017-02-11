class ApplicationMailer < ActionMailer::Base
	include Resque::Mailer
  default from: "Idipops <no-reply@idipops.com>"
  layout 'mailer'

  def convert_linebreaks input_str
  	input_str.gsub(/(?:\r\n|\r|\n)/, '<br/>').html_safe
  end

  def translate_reject_reason reject_reason
  	if reject_reason == 'spam' || reject_reason == 'inapropriate' || reject_reason == 'cheating'
      I18n.t("classified_ad.#{reject_reason}")
  	else
      convert_linebreaks reject_reason
  	end
  end
  
end