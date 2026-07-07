# frozen_string_literal: true

require "spec_helper"

describe "Department admin browsing an assembly", :versioning do
  let(:organization) { create(:organization) }
  let(:department) { create(:department, organization:) }
  let(:department_admin) { create(:department_admin, :confirmed, organization:, department:) }

  let!(:assembly) { create(:assembly, organization:, department:) }

  before do
    switch_to_host(organization.host)
    login_as department_admin, scope: :user
  end

  # Regression test for a bug where Decidim::Assemblies::AssembliesWithUserRole
  # (decorated to widen results for department admins) ignored the requested
  # `role`, so a department admin looked like they held every role (admin,
  # collaborator, moderator, valuator) on their department's assemblies. Since
  # Decidim::Assemblies::Permissions#collaborator_action? allows reading ANY
  # subject for collaborators, this leaked global, organization-wide admin
  # sections (static pages, the admin activity log) into the sidebar while
  # browsing an assembly the department admin legitimately manages.
  context "when inside their own assembly" do
    before { visit decidim_admin_assemblies.edit_assembly_path(assembly) }

    it "does not show global admin sections in the sidebar" do
      expect(page).to have_no_link("Pages")
      expect(page).to have_no_link("Admin activity log")
    end
  end

  context "when trying to access global admin sections directly" do
    it "cannot read the static pages list" do
      visit decidim_admin.static_pages_path
      expect(page).to have_content("You are not authorized to perform this action")
    end

    it "cannot read the admin activity log" do
      visit decidim_admin.logs_path
      expect(page).to have_content("You are not authorized to perform this action")
    end
  end
end
