# frozen_string_literal: true

require "spec_helper"

describe "Admin manages assemblies", :versioning do
  let(:organization) { create(:organization) }
  let(:department) { create(:department, organization:) }
  let(:department_admin) { create(:department_admin, :confirmed, organization:, department:) }

  let!(:assembly_w_department) { create(:assembly, organization:, department:) }
  let!(:assembly_wo_department) { create(:assembly, organization:) }

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

  it "sees only assemblies in the same department" do
    visit_admin_assemblies_list
    expect(page).to have_content(assembly_w_department.title["en"])
    expect(page).to have_no_content(assembly_wo_department.title["en"])
  end

  context "when department_admin has a user_role in an assembly_wo_department" do
    let!(:assembly_user_role) do
      create(:assembly_user_role, user: department_admin, assembly: assembly_wo_department)
    end

    it "sees both assemblies" do
      visit_admin_assemblies_list
      expect(page).to have_content(assembly_w_department.title["en"])
      expect(page).to have_content(assembly_wo_department.title["en"])
    end
  end
end
