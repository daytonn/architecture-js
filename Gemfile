source :rubygems

gem "listen"
gem "ejs"
gem "jsmin", "~> 1.0.1"

group :test do
  gem "simplecov", "~> 0.5.4", :require => false
  gem 'rb-fsevent', :require => false if RUBY_PLATFORM =~ /darwin/i
  gem 'guard-rspec'
end

group :development do
  gem "rspec", "~> 2.8.0"
  gem "nyan-cat-formatter"
  gem "bundler"
  gem "jeweler", "~> 1.8.3"
end
