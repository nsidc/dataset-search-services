# frozen_string_literal: true

require 'rspec/core/formatters/base_text_formatter'
require 'rspec/core/formatters/console_codes'

class CustomFormatter < RSpec::Core::Formatters::BaseTextFormatter
  RSpec::Core::Formatters.register self, :example_passed, :example_failed, :start_dump

  def initialize(output)
    super(output)
    @output = output
  end

  def example_passed(notification)
    @output << ".\n"
  end

  def example_failed(notification)
    failed = notification.example.metadata.keys.select { |k| k.to_s.include? 'search_' }.to_s || ''
    @output << RSpec::Core::Formatters::ConsoleCodes.wrap("F#{failed}\n", :failure)
  end

  def start_dump(notification)
    @output << "\n"
  end
end
