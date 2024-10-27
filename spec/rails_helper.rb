require 'database_cleaner/active_record'
require 'spec_helper'
require 'capybara/rspec'
require 'action_mailer'  # この行を追加
ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'

abort("The Rails environment is running in production mode!") if Rails.env.production?

# support/ディレクトリ内のファイルを読み込む
Dir[Rails.root.join('spec', 'support', '**', '*.rb')].sort.each { |f| require f }

require 'rspec/rails'
require 'capybara/rails'

begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  abort e.to_s.strip
end

RSpec.configure do |config|
  config.fixture_path = Rails.root.join('spec/fixtures')
  config.use_transactional_fixtures = true

  # システムスペック用の設定
  config.before(:each, type: :system) do
    driven_by :rack_test
  end

  config.before(:each, type: :system, js: true) do
    driven_by :selenium_chrome_headless
  end

  config.infer_spec_type_from_file_location!
  config.include FactoryBot::Syntax::Methods
  config.filter_rails_from_backtrace!

  # Database Cleaner設定
  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end

  # ヘルパーモジュールの設定
  config.include LoginHelper, type: :system
end