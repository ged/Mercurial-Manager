# -*- ruby -*-
# frozen_string_literal: true

require 'simplecov' if ENV['COVERAGE']

require 'rspec'

require 'loggability/spechelpers'


### Mock with RSpec
RSpec.configure do |config|
	config.expect_with( :rspec ) do |expectations|
		expectations.include_chain_clauses_in_custom_matcher_descriptions = true
		expectations.syntax = :expect
	end

	config.mock_with( :rspec ) do |mock|
		mock.syntax = :expect
	end

	config.disable_monkey_patching!
	config.example_status_persistence_file_path = "spec/.status"
	config.filter_run :focus
	config.filter_run_when_matching :focus
	config.order = :random
	config.profile_examples = 5
	config.run_all_when_everything_filtered = true
	config.shared_context_metadata_behavior = :apply_to_host_groups
	config.warnings = true

	config.include( Loggability::SpecHelpers )
end


