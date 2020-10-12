require 'rails_helper'
require 'huginn_agent/spec_helper'

describe Agents::BraveCatalogAvailabilityCounterAgent do
  before(:each) do
    @valid_options = Agents::BraveCatalogAvailabilityCounterAgent.new.default_options
    @checker = Agents::BraveCatalogAvailabilityCounterAgent.new(:name => "BraveCatalogAvailabilityCounterAgent", :options => @valid_options)
    @checker.user = users(:bob)
    @checker.save!
  end

  pending "add specs here"
end
