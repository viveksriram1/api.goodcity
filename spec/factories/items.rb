# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :item do
    donor_description { generate(:donor_descriptions) }
    state             'submitted'

    association :donor_condition
    association :package_type
    association :offer

    trait :draft do
      donor_description nil
      state             'draft'
    end

    trait :with_packages do
      packages { create_list(:package, 2) }
    end

    trait :with_inventory_packages do
      after(:create) do |item|
        create_list(:package, 2, :with_set_item, :package_with_locations, item: item)
      end
    end

    trait :with_received_packages do
      packages { create_list(:package, 2, state: :received) }
    end

    trait :with_images do
      images { create_list(:image, 1) << create(:image, favourite: true) }
    end

    trait :paranoid do
      state  { ["submitted", "accepted", "rejected"].sample }
      images { create_list(:image, 2) }
    end

    trait :with_messages do
      transient do
        messages_count 1
      end
      after(:create) do |item, evaluator|
        create_list(:message, evaluator.messages_count,
          sender: item.offer.created_by,
          offer: item.offer,
          item: item)
      end
    end

    trait :rejected do
      state              'rejected'
      association        :rejection_reason
      association        :offer, :under_review
      reject_reason      { generate(:reject_reasons) }
      rejection_comments { FFaker::Lorem.sentence }
    end
  end

  sequence :reject_reasons do |n|
    ["Sorry, this item is too large.",
     "The item condition is not suitable for our recipients.",
     "We are generally unable to find suitable homes for this sort of item."
    ].sample
  end

  sequence :donor_descriptions do |n|
    ["Washing machine. Good working order. 2 years old.",
     "Children's bunk beds. 10 years old",
     "Bookshelf. Slightly warped.",
     "Camera. SLR with 3 extra lenses",
    ].sample
  end
end
