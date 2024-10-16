# frozen_string_literal: true

ENV['RAILS_ENV'] ||= 'test'
require 'spec_helper'
require_relative '../config/environment'

require File.expand_path('../config/environment', __dir__)
Rails.root.glob('spec/support/**/*.rb').sort.each { |f| require f }

require 'rspec/rails'
require 'support/factory_bot'

abort('The Rails environment is running in production mode!') if Rails.env.production?

begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => error
  abort error.to_s.strip
end
RSpec.configure do |config|
  config.fixture_path = Rails.root.join('spec/fixtures')
  config.use_transactional_fixtures = false
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!
end
