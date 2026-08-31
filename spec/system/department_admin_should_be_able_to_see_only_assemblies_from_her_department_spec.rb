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

  it "can actually export an assembly in their own department" do
    visit_admin_assemblies_list
    within "tr", text: assembly_w_department.title["en"] do
      find(".action-icon--export").click
    end
    expect(page).to have_content("Your export is currently in progress")
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

  context "when there are several assemblies in the department with different weights" do
    let(:assembly_w_department) { create(:assembly, organization:, department:, weight: 4, title: { "en" => "Assembly Z" }) }
    let!(:assembly_c) { create(:assembly, organization:, department:, weight: 3, title: { "en" => "Assembly C" }) }
    let!(:assembly_a) { create(:assembly, organization:, department:, weight: 1, title: { "en" => "Assembly A" }) }
    let!(:assembly_b) { create(:assembly, organization:, department:, weight: 2, title: { "en" => "Assembly B" }) }

    it "lists them ordered by weight, same as a regular admin would see them" do
      visit_admin_assemblies_list

      titles = page.all(".table-list tbody .table-list__title-ellipsis a").map(&:text)
      expect(titles).to eq(["Assembly A", "Assembly B", "Assembly C", "Assembly Z"])
    end
  end
end
