FactoryGirl.define do
    factory :account_email do
        sequence :email do |n|
          "email#{n}@example.com"
        end
        association :account, factory: :account
    end
end
