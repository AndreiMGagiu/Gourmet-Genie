# frozen_string_literal: true

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins ENV.fetch('CLIENT_APP_URL', 'test')
    resource '/api/*',
      headers: :any,
      methods: %i[get post put patch delete options head],
      credentials: true
  end
end
