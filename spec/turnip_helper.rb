# frozen_string_literal: true

Dir.glob('spec/acceptance/steps/**/*steps.rb') { |f| load f, true }
