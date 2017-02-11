FactoryGirl.define do
  factory :address do
    formatted_address FFaker::Address.street_address
    action_range Random.rand(1..10)
    association :user, factory: :user
    latitude FFaker::Geolocation.lat
    longitude FFaker::Geolocation.lng
  end
end
