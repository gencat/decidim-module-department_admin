# frozen_string_literal: true

require "spec_helper"

describe "Admin manages participatory processes", :versioning do
  let(:organization) { create(:organization) }
  let(:area) { create(:area) }
  let(:department_admin) { create(:department_admin, :confirmed, organization:, area:) }

  let!(:participatory_process_w_area) do
    create(:participatory_process, organization:, area:)
  end
  let!(:participatory_process_wo_area) do
    create(:participatory_process, organization:)
  end

  def visit_admin_processes_list
    switch_to_host(organization.host)
    login_as department_admin, scope: :user
    visit decidim_admin_participatory_processes.participatory_processes_path
  end

  it "sees the import button" do
    visit_admin_processes_list
    expect(page).to have_content("Import")
  end

  it "sees the export button" do
    visit_admin_processes_list
    expect(page).to have_css(".icon--data-transfer-download")
  end

  it "sees only processes in the same area" do
    visit_admin_processes_list
    expect(page).to have_content(participatory_process_w_area.title["en"])
    expect(page).to have_no_content(participatory_process_wo_area.title["en"])
  end

  context "when department_admin has a user_role in a participatory_process_wo_area" do
    let!(:participatory_process_user_role) do
      create(:participatory_process_user_role, user: department_admin, participatory_process: participatory_process_wo_area)
    end

    it "sees both processes" do
      visit_admin_processes_list
      expect(page).to have_content(participatory_process_w_area.title["en"])
      expect(page).to have_content(participatory_process_wo_area.title["en"])
    end
  end
end
