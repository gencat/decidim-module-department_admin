# frozen_string_literal: true

require 'spec_helper'

describe 'Department admin should be able to access Admin Dashboard', type: :system do
  let(:organization) { create(:organization) }
  let(:area) { create(:area) }
  let(:department_admin) { create(:department_admin, :confirmed, organization: organization, area: area) }
  let!(:process) { create(:participatory_process, :published, organization: organization, area: area) }

  before do
    switch_to_host(organization.host)
    login_as department_admin, scope: :user
    visit decidim_admin.root_path
  end

  it 'should be able to access the admin Dashboard' do
    expect(page).to have_content('DASHBOARD')
    expect(page).to have_content('Welcome to the Decidim Admin Panel.')
  end

  context 'when accessing the dashboard some left menu elements should be accessible' do
    it "should be able to access 'Processes'" do
      expect(page).to have_content('PROCESSES')
      click_link 'Processes'
      expect(page).to have_current_path '/admin/participatory_processes'
      expect(page).to have_content('PARTICIPATORY PROCESSES')
    end

    it "should be able to access 'Assemblies'" do
      expect(page).to have_content('ASSEMBLIES')
      click_link 'Assemblies'
      expect(page).to have_current_path '/admin/assemblies'
      expect(page).to have_content('NEW ASSEMBLY')
    end

    it "should be able to access 'Newsletter'" do
      expect(page).to have_content('NEWSLETTER')
      click_link 'Newsletter'
      expect(page).to have_current_path '/admin/newsletters'
      expect(page).to have_content('NEW NEWSLETTER')
    end
    # TODO: not supported at the moment
    # it "should be able to access 'Initiatives'"
    # it "should be able to access 'Consultations'"
    # it "should be able to access 'Conferences'"
  end

  context 'when accessing the dashboard some left menu elements should NOT be accessible' do
    it "should NOT be able to access 'Pages'" do
      expect(page).to_not have_content('PAGES')
    end
    it "should NOT be able to access 'Participants'" do
      expect(page).to_not have_content('PARTICIPANTS')
    end
    it "should NOT be able to access 'Settings'" do
      expect(page).to_not have_content('SETTINGS')
    end
    it "should NOT be able to access 'Admin Activity Log'" do
      expect(page).to_not have_content('ADMIN ACTIVITY LOG')
    end
    it "should NOT be able to access 'OAuth Applications'" do
      expect(page).to_not have_content('OAUTH APPLICATIONS')
    end
  end
end
