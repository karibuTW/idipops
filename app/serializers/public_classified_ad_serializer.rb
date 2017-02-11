class PublicClassifiedAdSerializer < BaseSerializer

  attributes :id,
             :title,
             :description,
             :created_at,
             :place_name,
             :start_date

  has_many :classified_ad_photos

  def description
    object.truncated_description
  end

  def place_name
    object.place.formatted_name
  end

end