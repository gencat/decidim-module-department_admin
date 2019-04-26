# frozen_string_literal: true

require 'spec_helper'

describe "Admin manages assemblies", versioning: true, type: :system do
  let(:organization) { create(:organization) }
  let(:area) { create(:area) }
  let(:department_admin) { create(:department_admin, :confirmed, organization: organization, area: area) }

  let!(:assembly_w_area) { create(:assembly, organization: organization, area: area) }
  let!(:assembly_wo_area) { create(:assembly, organization: organization) }

  before do
    switch_to_host(organization.host)
    login_as department_admin, scope: :user
    visit decidim_admin_assemblies.assemblies_path
  end

  it "should see only processes in the same area" do
    expect(page).to have_content(assembly_w_area.title['en'])
    expect(page).to_not have_content(assembly_wo_area.title['en'])
  end
end
