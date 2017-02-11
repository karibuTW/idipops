FactoryGirl.define do
    factory :user do
        first_name FFaker::Name.first_name
        last_name FFaker::Name.last_name
        company_name FFaker::CompanyIT.name
        user_type :user
        association :account, factory: :account
        trait :as_pro do
            user_type = :pro
        end
        trait :particulier do
            user_type = :particulier
        end
    end
end
