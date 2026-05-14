# frozen_string_literal: true

require "spec_helper"

describe "Admin manages participatory processes", :versioning do
  let(:organization) { create(:organization) }
  let(:department) { create(:department, organization:) }
  let(:department_admin) { create(:department_admin, :confirmed, organization:, department:) }

  let!(:participatory_process_w_department) do
    create(:participatory_process, organization:, department:)
  end
  let!(:participatory_process_wo_department) do
    create(:participatory_process, organization:)
  end

  def visit_admin_processes_list
    switch_to_host(organization.host)
    login_as department_admin, scope: :user
    visit decidim_admin_participatory_processes.participatory_processes_path
  end

  it "sees the import button" do
    visit_admin_processes_list

    within_admin_menu do
      expect(page).to have_content("Import")
    end
  end

  it "sees the export button" do
    visit_admin_processes_list
    expect(page).to have_css(".action-icon--export")
  end

  it "sees only processes in the same department" do
    visit_admin_processes_list
    expect(page).to have_content(participatory_process_w_department.title["en"])
    expect(page).to have_no_content(participatory_process_wo_department.title["en"])
  end

  context "when department_admin has a user_role in a participatory_process_wo_department" do
    let!(:participatory_process_user_role) do
      create(:participatory_process_user_role, user: department_admin, participatory_process: participatory_process_wo_department)
    end

    it "sees both processes" do
      visit_admin_processes_list
      expect(page).to have_content(participatory_process_w_department.title["en"])
      expect(page).to have_content(participatory_process_wo_department.title["en"])
    end
  end
end
