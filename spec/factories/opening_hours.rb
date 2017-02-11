FactoryGirl.define do
  factory :opening_hour do
    day Random.rand(0..6)
    association :address, factory: :address
    periods [
      {
        open: {
          hour: Random.rand(1..11),
          minute: Random.rand(0..59)
        },
        close: {
          hour: Random.rand(13..23),
          minute: Random.rand(0..59)
        }
      }
    ]
  end
end
