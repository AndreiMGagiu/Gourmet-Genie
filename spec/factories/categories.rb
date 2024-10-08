# frozen_string_literal: true

FactoryBot.define do
  factory :category do
    sequence(:name) { |n| "Category #{n}" }
    trait :white_bread do
      name { 'White Bread' }
    end

    trait :pizza do
      name { 'Pizza' }
    end

    trait :vegan do
      name { 'Vegan Recipes' }
    end

    trait :gluten_free do
      name { 'Gluten-Free Turkey Meatballs' }
    end
  end
end
