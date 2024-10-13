# frozen_string_literal: true

FactoryBot.define do
  factory :rating do
    score { rand(1..5) }
    recipe
    user

    trait :five_star do
      score { 5 }
    end

    trait :one_star do
      score { 1 }
    end
  end
end
