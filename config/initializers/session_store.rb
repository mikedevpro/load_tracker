cross_site_session_cookies = ENV["SESSION_COOKIE_SECURE"] == "true" || Rails.env.production?

Rails.application.config.session_store :cookie_store,
  # For cross-site credentialed requests, browsers require SameSite=None and Secure.
  # In non-HTTPS local environments, keep SameSite:Lax by default unless
  # SESSION_COOKIE_SECURE=true is explicitly enabled.
  key: "_load_tracker_session",
  same_site: cross_site_session_cookies ? :none : :lax,
  secure: cross_site_session_cookies
