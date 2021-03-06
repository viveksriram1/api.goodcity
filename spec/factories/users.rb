# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user, aliases: [:sender] do
    association :address

    first_name        { FFaker::Name.first_name }
    last_name         { FFaker::Name.last_name }
    mobile            { generate(:mobile) }
    last_connected    { 2.days.ago }
    last_disconnected { 1.day.ago }
    disabled          { false }
    initialize_with   { User.find_or_initialize_by(mobile: mobile) }

    association :image

    trait :reviewer do
      association :permission, factory: :reviewer_permission
    end

    trait :supervisor do
      association :permission, factory: :supervisor_permission
    end

    trait :administrator do
      association :permission, factory: :administrator_permission
    end

    trait :api_user do
      association :permission, factory: :api_write_permission
    end

    trait :system do
      first_name "GoodCity"
      last_name  "Team"
      mobile     SYSTEM_USER_MOBILE
      association :permission, factory: :system_permission
    end

  end

  factory :user_with_token, parent: :user do
    mobile { generate(:mobile) }
    after(:create) do |user|
      user.auth_tokens << create(:scenario_before_auth_token)
    end
  end

end
