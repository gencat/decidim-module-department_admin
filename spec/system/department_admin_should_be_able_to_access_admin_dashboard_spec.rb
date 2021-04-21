# frozen_string_literal: true

require "spec_helper"

describe "Department admin should be able to access Admin Dashboard", type: :system do
  let(:organization) { create(:organization) }
  let(:area) { create(:area) }
  let(:department_admin) { create(:department_admin, :confirmed, organization: organization, area: area, accepted_tos_version: Time.current) }
  let!(:process) { create(:participatory_process, :published, organization: organization, area: area) }

  before do
    switch_to_host(organization.host)
    login_as department_admin, scope: :user
    visit decidim_admin.root_path
  end

  it "is able to access the admin Dashboard" do
    expect(page).to have_content("Dashboard")
    expect(page).to have_content("Welcome to the Decidim Admin Panel.")
  end

  context "when accessing the dashboard some left menu elements should be accessible" do
    it "is able to access 'Processes'" do
      expect(page).to have_content("Processes")
      click_link "Processes"
      expect(page).to have_current_path "/admin/participatory_processes"
      expect(page).to have_content("Participatory processes")
    end

    it "is able to access 'Assemblies'" do
      expect(page).to have_content("Assemblies")
      click_link "Assemblies"
      expect(page).to have_current_path "/admin/assemblies"
      expect(page).to have_content("New assembly")
    end

    it "is able to access 'Newsletter'" do
      expect(page).to have_content("Newsletter")
      click_link "Newsletter"
      expect(page).to have_current_path "/admin/newsletters"
      expect(page).to have_content("New newsletter")
    end

    it "is able to access 'Conferences'" do
      expect(page).to have_content("Conferences")
      click_link "Conferences"
      expect(page).to have_current_path "/admin/conferences"
      expect(page).to have_content("New conference")
    end
    # TODO: not supported at the moment
    # it "should be able to access 'Initiatives'"
    # it "should be able to access 'Consultations'"
    # it "should be able to access 'Conferences'"
  end

  context "when accessing the dashboard some left menu elements should NOT be accessible" do
    it "is not able to access 'Pages'" do
      expect(page).not_to have_content("Pages")
    end

    it "is not able to access 'Participants'" do
      expect(page).not_to have_content("Participants")
    end

    it "is not able to access 'Settings'" do
      expect(page).not_to have_content("Settings")
    end

    it "is not able to access 'Admin Activity Log'" do
      expect(page).not_to have_content("Admin activity log")
    end
  end
end
