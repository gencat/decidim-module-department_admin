# frozen_string_literal: true

require 'spec_helper'

describe 'Admin manages assemblies', versioning: true, type: :system do
  let(:organization) { create(:organization) }
  let(:area) { create(:area) }
  let(:department_admin) { create(:department_admin, :confirmed, organization: organization, area: area) }

  let!(:assembly_w_area) { create(:assembly, organization: organization, area: area) }
  let!(:assembly_wo_area) { create(:assembly, organization: organization) }

  def visit_admin_assemblies_list
    switch_to_host(organization.host)
    login_as department_admin, scope: :user
    visit decidim_admin_assemblies.assemblies_path
  end

  it 'should see the import button' do
    visit_admin_assemblies_list
    expect(page).to have_content("Import")
  end

  it 'should see the export button' do
    visit_admin_assemblies_list
    expect(page).to have_css("icon--data-transfer-download")
  end

  it 'should see only processes in the same area' do
    visit_admin_assemblies_list
    expect(page).to have_content(assembly_w_area.title['en'])
    expect(page).to_not have_content(assembly_wo_area.title['en'])
  end

  context "when department_admin has a user_role in an assembly_wo_area" do
    let!(:assembly_user_role) do
      create(:assembly_user_role, user: department_admin, assembly: assembly_wo_area)
    end

    it "should see both assemblies" do
      visit_admin_assemblies_list
      expect(page).to have_content(assembly_w_area.title['en'])
      expect(page).to have_content(assembly_wo_area.title['en'])
    end
  end
end
