require 'rails_helper'
require 'huginn_agent/spec_helper'

describe Agents::BraveCatalogAvailabiltyCounterAgent do
  before(:each) do
    @valid_options = Agents::BraveCatalogAvailabiltyCounterAgent.new.default_options
    @checker = Agents::BraveCatalogAvailabiltyCounterAgent.new(:name => "BraveCatalogAvailabiltyCounterAgent", :options => @valid_options)
    @checker.user = users(:bob)
    @checker.save!
  end

  pending "add specs here"
end
