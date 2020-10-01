# -*- ruby -*-
# frozen_string_literal: true

require_relative 'spec_helper'

require 'rspec'
require 'mercurial_manager'


RSpec.describe( MercurialManager ) do

	it "has a semantic version" do
		expect( described_class::VERSION ).to match( /^\d+\.\d+\.\d+/ )
	end

end

