Rails.application.config.middleware.insert_before 0, Rack::Cors do
  frontend_origins = ENV["FRONTEND_ORIGINS"]
    .to_s
    .split(",")
    .map(&:strip)
    .reject(&:empty?)

  normalize_origin = ->(value) do
    next if value.blank?

    value = value.to_s.strip
    next if value.empty?

    if value.match?(%r{\Ahttps?://})
      value
    else
      "https://#{value}"
    end
  end

  legacy_frontend_origin = normalize_origin.call(ENV["FRONTEND_ORIGIN"])
  frontend_origins << legacy_frontend_origin if legacy_frontend_origin

  [ENV["RENDER_EXTERNAL_HOSTNAME"], ENV["RENDER_EXTERNAL_URL"], ENV["HEROKU_APP_NAME"], ENV["VERCEL_URL"], ENV["VERCEL_BRANCH_URL"], ENV["FRONTEND_HOST"]].each do |candidate|
    next if candidate.to_s.blank?

    normalized = normalize_origin.call(candidate)
    frontend_origins << normalized if normalized
  end

  frontend_origins.compact!
  frontend_origins.uniq!

  if frontend_origins.empty? && Rails.env.production? && ENV["ALLOW_VERCEL_ORIGINS"] == "true"
    frontend_origins = [/https:\/\/.*\.vercel\.app/]
  end

  if frontend_origins.empty?
    if Rails.env.production?
      Rails.logger.warn(
        "No CORS origins configured. Set FRONTEND_ORIGINS (preferred), FRONTEND_ORIGIN, FRONTEND_HOST, or allow via VERCEL_URL/VERCEL_BRANCH_URL."
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
