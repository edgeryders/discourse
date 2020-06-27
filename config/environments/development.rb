# frozen_string_literal: true

Discourse::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # In the development environment your application's code is reloaded on
  # every request.  This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Log error messages when you accidentally call methods on nil.
  config.eager_load = false

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Do not compress assets
  config.assets.compress = false

  # Don't Digest assets, makes debugging uglier
  config.assets.digest = false

  config.assets.debug = false

  # Raise an error on page load if there are pending migrations
  config.active_record.migration_error = :page_load
  config.watchable_dirs['lib'] = [:rb]

  config.handlebars.precompile = true

  # we recommend you use mailcatcher https://github.com/sj26/mailcatcher
  config.action_mailer.smtp_settings = { address: "localhost", port: 1025 }

  config.action_mailer.raise_delivery_errors = true

  config.log_level = ENV['DISCOURSE_DEV_LOG_LEVEL'] if ENV['DISCOURSE_DEV_LOG_LEVEL']

  if ENV['RAILS_VERBOSE_QUERY_LOGS'] == "1"
    config.active_record.verbose_query_logs = true
  end

  if defined?(BetterErrors)
    BetterErrors::Middleware.allow_ip! ENV['TRUSTED_IP'] if ENV['TRUSTED_IP']

    if defined?(Unicorn) && ENV["UNICORN_WORKERS"].to_i != 1
      # BetterErrors doesn't work with multiple unicorn workers. Disable it to avoid confusion
      Rails.configuration.middleware.delete BetterErrors::Middleware
    end
  end

  config.load_mini_profiler = true
  if hosts = ENV['DISCOURSE_DEV_HOSTS']
    config.hosts.concat(hosts.split(","))
  end

  require 'middleware/turbo_dev'
  config.middleware.insert 0, Middleware::TurboDev
  require 'middleware/missing_avatars'
  config.middleware.insert 1, Middleware::MissingAvatars

  config.enable_anon_caching = false
  if RUBY_ENGINE == "ruby"
    require 'rbtrace'
  end

  if emails = GlobalSetting.developer_emails
    config.developer_emails = emails.split(",").map(&:downcase).map(&:strip)
  end

  if defined?(Rails::Server) || defined?(Puma) || defined?(Unicorn)
    require 'stylesheet/watcher'
    STDERR.puts "Starting CSS change watcher"
    @watcher = Stylesheet::Watcher.watch
  end

  config.after_initialize do
    if ENV["RAILS_COLORIZE_LOGGING"] == "1"
      config.colorize_logging = true
    end

    if ENV["RAILS_VERBOSE_QUERY_LOGS"] == "1"
      ActiveRecord::LogSubscriber.backtrace_cleaner.add_silencer do |line|
        line =~ /lib\/freedom_patches/
      end
    end

    if ENV['BULLET']
      Bullet.enable = true
      Bullet.rails_logger = true
    end
  end

  config.hosts << "dc.test"
end
