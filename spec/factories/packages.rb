# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :package do
    quantity    { rand(5) + 1 }
    length      { rand(199) + 1 }
    width       { rand(199) + 1 }
    height      { rand(199) + 1 }
    notes       { FFaker::Lorem.paragraph }
    state       'expecting'
    received_quantity 1

    received_at nil
    rejected_at nil

    association :package_type
    association :location

    trait :with_item do
      association :item
    end

    trait :stockit_package do
      inventory_number {rand(1000000).to_s.rjust(6,'0')}
      sequence(:stockit_id) { |n| n }
    end

    trait :with_set_item do
      inventory_number {rand(1000000).to_s.rjust(6,'0')}

      sequence(:stockit_id) { |n| n }
      item
      set_item_id { item.id }
      state "received"
    end

    trait :received do
      state "received"
      received_at { Time.now }
      inventory_number {rand(1000000).to_s.rjust(6,'0')}
      sequence(:stockit_id) { |n| n }
    end
  end
end
