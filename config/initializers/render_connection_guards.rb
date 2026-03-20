if Rails.env.production?
  missing_vars = []

  missing_vars << "DATABASE_URL (required for PostgreSQL production connection)" if ENV["DATABASE_URL"].to_s.strip.empty?
  skip_cors_check = ENV["SKIP_FRONTEND_ORIGIN_CHECK"] == "true"

  action_cable_adapter = ENV["REDIS_URL"].to_s.strip.empty? ? "async" : "redis"
  Rails.logger.info("Action Cable adapter configured as: #{action_cable_adapter}")

  redis_needed = ENV["SOLID_QUEUE_IN_PUMA"].to_s == "true" ||
    ENV["REDIS_ENABLED"].to_s == "true"
  if redis_needed && ENV["REDIS_URL"].to_s.strip.empty?
    missing_vars << "REDIS_URL (required by enabled queue/cable features)"
  elsif ENV["REDIS_URL"].to_s.strip.empty?
    Rails.logger.warn(
      "REDIS_URL is not set; Action Cable will fall back to the `async` adapter in this deploy."
    )
  end

  unless skip_cors_check
    frontend_origins = ENV["FRONTEND_ORIGINS"].to_s.split(",").map(&:strip).reject(&:empty?)
    frontend_origin = ENV["FRONTEND_ORIGIN"].to_s.strip
    render_host = ENV["RENDER_EXTERNAL_HOSTNAME"].to_s.strip
    render_external = ENV["RENDER_EXTERNAL_URL"].to_s.strip
    heroku_app_name = ENV["HEROKU_APP_NAME"].to_s.strip
    vercel_host = ENV["VERCEL_URL"].to_s.strip
    vercel_branch_host = ENV["VERCEL_BRANCH_URL"].to_s.strip
    frontend_host = ENV["FRONTEND_HOST"].to_s.strip

    has_frontend_origin = frontend_origins.present? ||
      frontend_origin.present? ||
      render_host.present? ||
      render_external.present? ||
      heroku_app_name.present? ||
      vercel_host.present? ||
      vercel_branch_host.present? ||
      frontend_host.present? ||
      ENV["ALLOW_VERCEL_ORIGINS"] == "true"

    missing_vars << "FRONTEND_ORIGINS or FRONTEND_ORIGIN (or RENDER_EXTERNAL_HOSTNAME/RENDER_EXTERNAL_URL/HEROKU_APP_NAME for fallback)" unless has_frontend_origin
  else
    Rails.logger.warn("Skipping production frontend-origin requirement because SKIP_FRONTEND_ORIGIN_CHECK=true")
  end

  unless missing_vars.empty?
    raise <<~MSG.strip
      Missing required production environment variable(s):
      #{missing_vars.map { |var| "- #{var}" }.join("\n")}
    MSG
  end
end
