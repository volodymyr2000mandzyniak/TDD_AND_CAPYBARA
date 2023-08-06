# frozen_string_literal: true

require_relative '../lib/parser'
require 'capybara/rspec'

Capybara.default_driver = :selenium_chrome

RSpec.configure do |config|
  config.include Capybara::DSL

  config.before(:each) do
    Capybara.app_host = 'https://hdrezka.co/'
    # Capybara.current_driver = :selenium
    Capybara.page.driver.browser.manage.window.maximize
  end

  config.after(:each) do
    Capybara.reset_sessions!
  end

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.disable_monkey_patching!
  config.warnings = true

  config.default_formatter = 'doc' if config.files_to_run.one?

  config.profile_examples = 10
  config.order = :random
  Kernel.srand config.seed
end
