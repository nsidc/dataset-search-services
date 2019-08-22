# frozen_string_literal: true

require 'rspec/core/formatters/base_text_formatter'

class CustomFormatter < RSpec::Core::Formatters::BaseTextFormatter
  RSpec::Core::Formatters.register self, :example_passed, :example_failed, :start_dump

  def initialize(output)
    super(output)
    @output = output
  end

  def example_passed(notification)
    @output << '.'
  end

  def example_failed(notification)
    failed = notification.example.metadata.keys.select { |k| k.to_s.include? 'search_' }.to_s || ''
    @output << "F#{failed}"
  end

  def start_dump(notification)
    @output << "\n"
  end
end
