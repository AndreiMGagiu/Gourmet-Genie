# frozen_string_literal: true

# spec/factories/recipe_ingredients.rb
FactoryBot.define do
  factory :recipe_ingredient do
    recipe
    ingredient
    quantity { Faker::Number.decimal(l_digits: 2, r_digits: 2) }
    unit { %w[grams ml cups tablespoons teaspoons pieces].sample }

    trait :with_custom_quantity do
      transient do
        custom_quantity { nil }
      end

      quantity { custom_quantity || Faker::Number.decimal(l_digits: 2, r_digits: 2) }
    end

    trait :with_custom_unit do
      transient do
        custom_unit { nil }
      end

      unit { custom_unit || %w[grams ml cups tablespoons teaspoons pieces].sample }
    end
  end
end
