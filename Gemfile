source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.3.0"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 7.0.8", ">= 7.0.8.4"

# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
gem "sprockets-rails"

# Use postgresql as the database for Active Record
gem "pg", "~> 1.1"

# Use the Puma web server [https://github.com/puma/puma]
gem "puma", "~> 5.0"

# Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem "importmap-rails"

# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem "turbo-rails"

# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem "stimulus-rails"

gem "jbuilder"

# Security
gem 'dotenv-rails', '~> 3.1'

gem "tzinfo-data", platforms: %i[ mingw mswin x64_mingw jruby ]

gem "bootsnap", require: false

group :development, :test do
  gem "debug", platforms: %i[ mri mingw x64_mingw ]
  gem 'pry-nav', '~> 1.0'
  gem 'pry-rails', '~> 0.3'
  gem 'factory_bot_rails'
  gem 'faker', '~> 3.4', '>= 3.4.2'

  # Code critics
  gem 'rubocop', '~> 1.66', require: false
  gem 'rubocop-factory_bot', '~> 2.26', require: false
  gem 'rubocop-performance', '~> 1.19', require: false
  gem 'rubocop-rails', '~> 2.21', require: false
  gem 'rubocop-rspec', '~> 2.24', require: false
  gem 'rubocop-thread_safety', '~> 0.5.1', require: false
end

group :development do
  gem "web-console"
end

group :test do
  gem 'database_cleaner-active_record', '~> 2.1'
  gem "capybara"
  gem "selenium-webdriver"
  gem "webdrivers"
  gem 'rspec-rails', '~> 6.1'
end
