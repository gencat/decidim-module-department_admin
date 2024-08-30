# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Overrides" do
  it "check failing tests in Decidim v0.28" do
    # Make test succeed spec/system/department_admin_should_be_able_to_manage_assemblies_spec.rbL73
    # expect(page).to have_current_path decidim_admin_assemblies.assemblies_path(q: { parent_id_eq: parent_assembly&.id })
    expect(Decidim.version).to be < "0.28"
  end
end
