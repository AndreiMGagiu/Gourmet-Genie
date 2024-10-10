# frozen_string_literal: true

FactoryBot.define do
  factory :recipe do
    title { Faker::Food.dish }
    cook_time { rand(5..60) }
    prep_time { rand(5..30) }
    cuisine { %w[Italian Mexican Japanese Indian French].sample }
    image { "https://example.com/food_images/#{rand(1..100)}.jpg" }

    association :category
    association :user

    trait :quick do
      cook_time { rand(5..15) }
      prep_time { rand(5..10) }
    end

    trait :medium do
      cook_time { rand(20..30) }
      prep_time { rand(10..20) }
    end

    trait :elaborate do
      cook_time { rand(45..120) }
      prep_time { rand(20..45) }
    end

    factory :pesto_pizza do
      title { 'Pesto Pita Pizza' }
      cook_time { 15 }
      prep_time { 15 }
      cuisine { 'Italian' }
      image { 'https://my-pesto-pizza.com' }
    end

    factory :vegetarian_pasta do
      title { 'Almond Citrus Couscous' }
      cook_time { 10 }
      prep_time { 20 }
      cuisine { 'Israeli' }
      image { 'https://my-veggie-pasta.com' }
    end
  end
end
