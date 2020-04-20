# frozen_string_literal: true

source 'https://rubygems.org'

ruby RUBY_VERSION

gemspec

# Bundler will treat runtime dependencies like base dependencies, and
# development dependencies will be added by default to the :development group.

# Declare any dependencies that are still in development here instead of in
# your gemspec. These might include edge Rails or gems from your path or
# Git. Remember to move these dependencies to your gemspec before releasing
# your gem to rubygems.org.

group :development, :test do
  gem 'bootsnap'
  gem 'byebug', platform: :mri
  gem 'faker', '~> 1.9'
  gem 'social-share-button'
  gem 'decidim'
  gem 'rubocop-rspec'
end

group :development do
  gem 'letter_opener_web', '~> 1.3'
  gem 'listen', '~> 3.1'
  gem 'spring', '~> 2.0'
  gem 'spring-watcher-listen', '~> 2.0'
  gem 'web-console', '~> 3.5'
end
