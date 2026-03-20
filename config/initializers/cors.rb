Rails.application.config.middleware.insert_before 0, Rack::Cors do
  frontend_origins = ENV["FRONTEND_ORIGINS"]
    .to_s
    .split(",")
    .map(&:strip)
    .reject(&:empty?)

  if frontend_origins.empty?
    legacy_frontend_origin = ENV["FRONTEND_ORIGIN"].to_s.strip
    frontend_origins = [legacy_frontend_origin] unless legacy_frontend_origin.empty?
  end

  if frontend_origins.empty?
    render_host = ENV["RENDER_EXTERNAL_HOSTNAME"] || ENV["RENDER_EXTERNAL_URL"] || ENV["HEROKU_APP_NAME"]
    frontend_origins = ["https://#{render_host}"] if render_host.present?
  end

  if frontend_origins.empty?
    if Rails.env.production?
      Rails.logger.warn(
        "No CORS origins configured. Set FRONTEND_ORIGINS (preferred) or FRONTEND_ORIGIN for cross-site credentialed requests."
      )
    else
      frontend_origins = ["http://localhost:5173"]
    end
  end

  allow do
    origins frontend_origins

    resource "*",
      headers: :any,
      methods: [:get, :post, :patch, :put, :delete, :options, :head],
      credentials: true
  end
end

# Be sure to restart your server when you modify this file.

# Avoid CORS issues when API is called from the frontend app.
# Handle Cross-Origin Resource Sharing (CORS) in order to accept cross-origin Ajax requests.

# Read more: https://github.com/cyu/rack-cors

# Rails.application.config.middleware.insert_before 0, Rack::Cors do
#   allow do
#     origins "example.com"
#
#     resource "*",
#       headers: :any,
#       methods: [:get, :post, :put, :patch, :delete, :options, :head]
#   end
# end
