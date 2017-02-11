class EmailTemplate < ActiveRecord::Base

	validates :name, presence: true, length: { minimum: 3, maximum: 250 }
  validates :subject, presence: true, length: { minimum: 3, maximum: 250 }, on: :update
  validates :body, presence: true, on: :update


def deliver_to(to, options = {})
    prms = {
      to: to,
      subject: subject,
      body: body,
      content_type: "text/html"
    }
    prms.merge!( options.delete_if{ |k, v| v.blank? })
    ApplicationMailer.mail( prms ) do |f|
      f.html
    end.deliver
  end
end