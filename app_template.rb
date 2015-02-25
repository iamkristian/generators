remove_file "README.rdoc"
create_file "README.md", "# TODO"

gem_group :test, :development do
  gem 'rspec-rails', '~> 3.1'
  gem 'forgery'
  gem 'capybara'
  gem 'poltergeist'
  gem 'pry'
  gem 'pry-byebug'
  gem 'dotenv-rails'
end

gem_group :development do
  gem 'capistrano-rails'
  gem 'timecop'
  gem "letter_opener"
  gem 'bullet'
  gem 'better_errors'
end

gem_group :test do
  gem 'simplecov', '~> 0.7.1', require: false
  gem 'rspec-activemodel-mocks'
  gem 'factory_girl_rails'
  gem 'database_cleaner'
  gem 'rb-fsevent'
end

gem 'foreman'
gem 'rails-i18n'
gem 'unicorn-rails'

if yes? "Do you want to use Devise?"
  gem 'devise'
  generate "devise:install"
  model_name = ask("What would you like the user model to be called? [user]")
  model_name = "user" if model_name.blank?
  generate "devise", model_name
end

if yes? "Do you want to use Simple_form?"
  gem 'simple_form'
  generate "simple_form:install"
end

if yes? "Is this app going to heroku?"
  gem_group :production, :staging do
    gem 'rails_12factor'
  end

  create_file 'config/environments/staging.rb' do <<-EOF
Rails.application.config do
  config.cache_classes = true
  config.eager_load = true

  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true
  config.serve_static_files = ENV['RAILS_SERVE_STATIC_FILES'].present?

  config.assets.js_compressor = :uglifier
  config.assets.compile = true
  config.assets.digest = true
  config.log_level = :debug

  config.i18n.fallbacks = true
  config.active_support.deprecation = :notify

  config.log_formatter = ::Logger::Formatter.new
  config.active_record.dump_schema_after_migration = false
end
EOF
  end

  # remember to add staging to config/secrets.yml


end

create_file '.env' do
  "RAILS_SERVE_STATIC_FILES=true"
end

inject_into_file 'config/environments/development.rb', after: "Rails.application.configure do\n" do <<-EOF
  config.action_mailer.delivery_method = :letter_opener
  config.action_mailer.default_url_options = { host: 'localhost:3000' }
EOF
end

# config/application.rb
application do <<-EOF

    config.time_zone = 'Copenhagen'
    config.i18n.default_locale = :da
    # For the rails-i18n gem
    config.i18n.available_locales = :da
    config.i18n.fallbacks = [ :da ]

    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.generators do |g|
      g.factory_girl      false
      g.stylesheets       false
      g.javascripts       false
      g.jbuilder          false
      g.test_framework    :rspec
      g.view_specs        false
      g.controller_specs  true
      g.request_specs     false
      g.routing_specs     false
    end
EOF
end

run "bundle install"

generate "rspec:install"

if yes? "Do you want to create a root controller?"
  name = ask("What should it be called?").underscore
  generate :controller, "#{name} index --skip-routes --skip-assets"
  route "root to: '#{name}\#index'"
end

git :init
