# frozen_string_literal: true

require "spec_helper"

# The "Edit" button in the front end of a space checks `admin_allowed_to?(:update, <space>)`
# with Decidim's own permissions chain, so these permissions are decorated by the module.
describe "Front end edit link permissions for department admins" do # rubocop:disable RSpec/DescribeClass
  let(:organization) { create(:organization) }
  let(:department) { create(:department, organization:) }
  let(:other_department) { create(:department, organization:) }
  let(:user) { create(:department_admin, :confirmed, organization:, department:) }

  def permission_for(permissions_class, subject, context)
    permission_action = Decidim::PermissionAction.new(scope: :admin, action: :update, subject:)
    permissions_class.new(user, permission_action, context).permissions
  end

  context "with processes" do
    let(:process) { create(:participatory_process, organization:, department:) }
    let(:other_process) { create(:participatory_process, organization:, department: other_department) }

    it "allows to update processes of their department" do
      expect(permission_for(Decidim::ParticipatoryProcesses::Permissions, :process, process:)).to be_allowed
    end

    it "does not allow to update processes of other departments" do
      permission = permission_for(Decidim::ParticipatoryProcesses::Permissions, :process, process: other_process)
      expect { permission.allowed? }.to raise_error(Decidim::PermissionAction::PermissionNotSetError)
    end
  end

  context "with assemblies" do
    let(:assembly) { create(:assembly, organization:, department:) }
    let(:other_assembly) { create(:assembly, organization:, department: other_department) }

    it "allows to update assemblies of their department" do
      expect(permission_for(Decidim::Assemblies::Permissions, :assembly, assembly:)).to be_allowed
    end

    it "does not allow to update assemblies of other departments" do
      permission = permission_for(Decidim::Assemblies::Permissions, :assembly, assembly: other_assembly)
      expect { permission.allowed? }.to raise_error(Decidim::PermissionAction::PermissionNotSetError)
    end
  end

  context "with conferences" do
    let(:conference) { create(:conference, organization:, department: other_department) }

    it "allows to update conferences of any department" do
      expect(permission_for(Decidim::Conferences::Permissions, :conference, conference:)).to be_allowed
    end
  end

  context "when the user is not a department admin" do
    let(:user) { create(:user, :confirmed, organization:) }
    let(:process) { create(:participatory_process, organization:, department:) }

    it "keeps Decidim's permissions" do
      permission = permission_for(Decidim::ParticipatoryProcesses::Permissions, :process, process:)
      expect(permission).not_to be_allowed
    end
  end
end
