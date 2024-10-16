# frozen_string_literal: true

FactoryBot.define do
  factory :app do
    name { "#{Faker::App.name} #{Faker::App.semantic_version}" }
    approved

    trait :approved do
      approved { true }
    end

    trait :rejected do
      approved { false }
    end
  end
end
