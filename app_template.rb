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
gem 'unicorn-rails'

if yes? "Do you want to use Devise?"
  gem 'devise'
end
if yes? "Do you want to use Simple_form?"
  gem 'simple_form'
end

inject_into_file 'config/environments/development.rb', after: "Rails.application.configure do\n" do <<-EOF
  config.action_mailer.delivery_method = :letter_opener
  config.action_mailer.default_url_options = { host: 'localhost:3000' }
EOF
end

run "bundle install"

generate "rspec:install"
generate "simple_form:install"

if yes? "Do you want to create a root controller?"
  name = ask("What should it be called?").underscore
  generate :controller, "#{name} index"
  route "route to: '#{name}\#index'"
end

git :init
