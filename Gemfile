source 'https://rubygems.org'

gem 'mongoid', :github => "mongoid/mongoid"

gem 'uuidtools', '>= 2.1.1'
gem 'i18n'
gem 'tzinfo'
gem 'differ', '>= 0.1.2'
gem 'encryptor', '~> 1.3.0'
gem 'rack'

group :development do
  gem "minitest", ">= 0"
  gem "yard", "~> 0.7"
  gem "rdoc", "~> 4.2"
  gem "bundler", "~> 1.0"
  gem "jeweler", "~> 2.0.1"
  gem "simplecov", ">= 0"

  gem 'timecop'
  gem 'pry'
end

group :test do
  begin
    gem "mongoid-grid_fs"
  rescue
    ''
  end
  gem "magic"
end
