# frozen_string_literal: true

require "spec_helper"

describe "Department admin should be able to access Admin Dashboard" do
  let(:organization) { create(:organization) }
  let(:area) { create(:area) }
  let(:department_admin) { create(:department_admin, :confirmed, organization:, area:, accepted_tos_version: Time.current) }
  let!(:process) { create(:participatory_process, :published, organization:, area:) }

  before do
    switch_to_host(organization.host)
    login_as department_admin, scope: :user
    visit decidim_admin.root_path
  end

  it "is able to access the admin Dashboard" do
    expect(page).to have_content("Dashboard")
  end

  context "when accessing the dashboard some left menu elements should be accessible" do
    it "is able to access 'Processes'" do
      expect(page).to have_content("Processes")
      click_link_or_button "Processes"
      expect(page).to have_current_path "/admin/participatory_processes"
      expect(page).to have_content("New process")
    end

    it "is able to access 'Assemblies'" do
      expect(page).to have_content("Assemblies")
      click_link_or_button "Assemblies"
      expect(page).to have_current_path "/admin/assemblies"
      expect(page).to have_content("New assembly")
    end

    it "is able to access 'Participants'" do
      expect(page).to have_content("Participants")
      click_link_or_button "Participants"
      expect(page).to have_current_path "/admin/users"
      expect(page).to have_content("New admin")
    end

    it "is able to access 'Newsletter'" do
      expect(page).to have_content("Newsletter")
      click_link_or_button "Newsletter"
      expect(page).to have_current_path "/admin/newsletters"
      expect(page).to have_content("New newsletter")
    end

    it "is able to access 'Conferences'" do
      expect(page).to have_content("Conferences")
      click_link_or_button "Conferences"
      expect(page).to have_current_path "/admin/conferences"
      expect(page).to have_content("New conference")
    end
    # TODO: not supported at the moment
    # it "should be able to access 'Initiatives'"
    # it "should be able to access 'Consultations'"
  end

  context "when accessing the dashboard some left menu elements should NOT be accessible" do
    it "is not able to access 'Pages'" do
      expect(page).to have_no_content("Pages")
    end

    it "is not able to access 'Settings'" do
      expect(page).to have_no_content("Settings")
    end

    it "is not able to access 'Admin Activity Log'" do
      expect(page).to have_no_content("Admin activity log")
    end
  end
end
