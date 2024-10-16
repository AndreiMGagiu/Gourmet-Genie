# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      get 'recipes/search', to: 'recipes#search'
      resources :recipe_ingredients, only: [:show]
    end
  end
end
