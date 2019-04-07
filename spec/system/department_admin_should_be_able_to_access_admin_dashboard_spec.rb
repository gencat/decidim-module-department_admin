# frozen_string_literal: true

require 'spec_helper'

describe 'Department admin should be able to access Admin Dashboard', type: :system do

  let(:organization) { create(:organization) }
  let(:area) { create(:area) }
  let(:department_admin) { create(:department_admin, :confirmed, organization: organization, area: area) }

  before do
    switch_to_host(organization.host)
    login_as department_admin, scope: :user
    visit decidim_admin.root_path
  end

  it "should be able to access the admin Dashboard" do
    expect(page).to have_content("DASHBOARD")
    expect(page).to have_content("Welcome to the Decidim Admin Panel.")
  end

  context "when accessing the dashboard some left menu elements should be accessible" do
    it "should be able to access 'Processes'" do
      expect(page).to have_content("PROCESSES")
      click_link "PROCESSES"
      expect(page).to have_content("PARTICIPATORY PROCESSES")
      expect(page).to have_current_path "/admin/participatory_processes"
    end

    it "should be able to access 'Assemblies'"
    it "should be able to access 'Newsletter'"
    # TODO
    # it "should be able to access 'Initiatives'"
    # it "should be able to access 'Consultations'"
    # it "should be able to access 'Conferences'"
  end

  context "when accessing the dashboard some left menu elements should NOT be accessible" do
    it "should NOT be able to access 'Pages'"
    it "should NOT be able to access 'Participants'"
    it "should NOT be able to access 'Configuration'"
    it "should NOT be able to access 'Admin Activity Log'"
    it "should NOT be able to access 'OAuth Applications'"
  end
end
