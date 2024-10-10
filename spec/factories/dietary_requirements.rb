# frozen_string_literal: true

FactoryBot.define do
  factory :dietary_requirement do
    sequence(:name) do |n|
      dietary_requirements = %w[
        Vegetarian Vegan Gluten-Free Dairy-Free Keto
        Low-Carb Paleo Pescatarian Nut-Free Soy-Free
        Low-Fat Low-Sodium Halal Kosher FODMAP
      ]
      dietary_requirements[n % dietary_requirements.length]
    end
  end
end
