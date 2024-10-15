# frozen_string_literal: true

require "spec_helper"

describe "Admin manages assemblies", :versioning do
  let(:organization) { create(:organization) }
  let(:area) { create(:area) }
  let(:department_admin) { create(:department_admin, :confirmed, organization:, area:) }

  let!(:assembly_w_area) { create(:assembly, organization:, area:) }
  let!(:assembly_wo_area) { create(:assembly, organization:) }

  def visit_admin_assemblies_list
    switch_to_host(organization.host)
    login_as department_admin, scope: :user
    visit decidim_admin_assemblies.assemblies_path
  end

  it "sees the import button" do
    visit_admin_assemblies_list

    within_admin_menu do
      expect(page).to have_content("Import")
    end
  end

  it "sees the export button" do
    visit_admin_assemblies_list
    expect(page).to have_css(".action-icon--export")
  end

  it "sees only processes in the same area" do
    visit_admin_assemblies_list
    expect(page).to have_content(assembly_w_area.title["en"])
    expect(page).to have_no_content(assembly_wo_area.title["en"])
  end

  context "when department_admin has a user_role in an assembly_wo_area" do
    let!(:assembly_user_role) do
      create(:assembly_user_role, user: department_admin, assembly: assembly_wo_area)
    end

    it "sees both assemblies" do
      visit_admin_assemblies_list
      expect(page).to have_content(assembly_w_area.title["en"])
      expect(page).to have_content(assembly_wo_area.title["en"])
    end
  end
end
