# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Overrides" do
  it "check overrides in Decidim v0.30" do
    pending "Pending because in 0.29 there is nothing to review"
    expect(Decidim.version).to be < "0.30"
  end
end
