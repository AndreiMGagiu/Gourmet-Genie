FactoryBot.define do
  factory :ingredient do
    sequence(:name) { |n| "Ingredient #{n}" }

    trait :spice do
      name { %w[Cinnamon Paprika Cumin Oregano Thyme].sample }
    end

    trait :vegetable do
      name { %w[Carrot Broccoli Spinach Tomato Bell_Pepper].sample }
    end

    trait :meat do
      name { %w[Chicken Beef Pork Lamb Turkey].sample }
    end
  end
end
