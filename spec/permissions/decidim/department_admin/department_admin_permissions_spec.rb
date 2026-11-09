# frozen_string_literal: true

require "spec_helper"

module Decidim
  module DepartmentAdmin
    describe Permissions do
      let(:organization) { create(:organization) }
      let(:department) { create(:department, organization: organization) }
      let(:area) { create(:area, organization: organization) }
      let(:area_type) { create(:area_type, organization: organization) }
      let!(:user) do
        create(:department_admin, :confirmed, organization: organization, department: department)
      end

      def should_allow_action(scope, action, subject)
        action = PermissionAction.new(scope:, action:, subject:)
        permissions = DepartmentAdmin::Permissions.new(user, action)
        expect(permissions.permissions).to be_allowed
      end

      def should_allow_action_with_ctx(scope, action, subject, ctx)
        action = PermissionAction.new(scope:, action:, subject:)
        permissions = DepartmentAdmin::Permissions.new(user, action, ctx)
        expect(permissions.permissions).to be_allowed
      end

      context "when user role is department_admin" do
        context "with simple permission actions" do
          it "allows accepted actions" do
            should_allow_action(:admin, :read, :admin_dashboard)
            should_allow_action(:admin, :read, :process_list)
            should_allow_action(:admin, :create, :process)
            should_allow_action(:admin, :read, :process_step)
            should_allow_action(:admin, :create, :process_step)
            should_allow_action(:admin, :read, :assembly_list)
            should_allow_action(:admin, :read, :assembly_user_role)
            should_allow_action(:admin, :create, :assembly)
            should_allow_action(:admin, :index, :newsletter)
            should_allow_action(:admin, :create, :newsletter)
            should_allow_action(:admin, :create, :attachment_collection)
            should_allow_action(:admin, :read, :conference_list)
            should_allow_action(:admin, :read, :conference_user_role)
            should_allow_action(:admin, :create, :conference)
          end

          context "when reading space private users" do
            let(:private_process) { create(:participatory_process, :private, organization:, department:) }
            let(:public_process) { create(:participatory_process, organization:, department:) }
            let(:private_assembly) { create(:assembly, :private, organization:, department:) }
            let(:public_assembly) { create(:assembly, :public, organization:, department:) }

            def read_private_users_permission(space)
              action = PermissionAction.new(scope: :admin, action: :read, subject: :space_private_user)
              DepartmentAdmin::Permissions.new(user, action, current_participatory_space: space).permissions
            end

            it "allows it when the space is private" do
              should_allow_action_with_ctx(:admin, :read, :space_private_user, current_participatory_space: private_process)
              should_allow_action_with_ctx(:admin, :read, :space_private_user, current_participatory_space: private_assembly)
            end

            it "does not allow it when the space is not private" do
              [public_process, public_assembly].each do |space|
                expect { read_private_users_permission(space).allowed? }.to raise_error(Decidim::PermissionAction::PermissionNotSetError)
              end
            end
          end

          it "allows managing process user roles" do
            [:index, :read, :create, :update, :invite, :destroy].each do |action|
              should_allow_action(:admin, action, :process_user_role)
            end
          end

          it "does not allow non accepted actions" do
            action = PermissionAction.new(scope: :admin, action: :write, subject: :admin_dashboard)
            permissions = DepartmentAdmin::Permissions.new(user, action)
            expect { permissions.permissions.allowed? }.to raise_error(Decidim::PermissionAction::PermissionNotSetError)
          end
        end

        context "with permission actions with context" do
          context "when acction is allowed and context is space_name" do
            it "allows accepted actions with expected context" do
              should_allow_action_with_ctx(:admin, :enter, :space_area, space_name: :processes)
              should_allow_action_with_ctx(:admin, :enter, :space_area, space_name: :assemblies)
              should_allow_action_with_ctx(:admin, :enter, :space_area, space_name: :conferences)
            end

            it "does not allow accepted actions with unexpected context" do
              action = PermissionAction.new(scope: :admin, action: :enter, subject: :space_area)
              permissions = DepartmentAdmin::Permissions.new(user, action, space_name: :custom_module)
              expect { permissions.permissions.allowed? }.to raise_error(Decidim::PermissionAction::PermissionNotSetError)
            end
          end

          context "when action is allowed and context is process" do
            context "when process and assembly have same department as department_admin" do
              let(:process) { create(:participatory_process, organization: organization, department: department) }
              let(:assembly) { create(:assembly, organization: organization, department: department) }
              let(:other_department) { create(:department, organization: organization) }
              let(:conference) { create(:conference, organization: organization, department: other_department) }

              it "allows accepted actions with expected context" do
                should_allow_action_with_ctx(:admin, :read, :participatory_space, current_participatory_space: process)
                should_allow_action_with_ctx(:admin, :update, :process, process:)
                pps = ParticipatoryProcessStep.new(participatory_process: process)
                should_allow_action_with_ctx(:admin, :update, :process_step, process_step: pps)
                should_allow_action_with_ctx(:admin, :destroy, :process_step, process_step: pps)
                should_allow_action_with_ctx(:admin, :update, :assembly, assembly:)
                should_allow_action_with_ctx(:admin, :update, :conference, conference:)
                # -> {permission_for?(requested_action, :admin, :read, :newsletter, restricted_rsrc: context[:newsletter])},
              end

              context "when meeting has same department as department_admin" do
                let(:meeting) { create(:meeting, participatory_space: process, department:) }

                it "allows accepted actions with expected context" do
                  should_allow_action(:admin, :create, :attachment)
                end
              end
            end

            context "when process has different department than department_admin" do
              let(:process) { create(:participatory_process, organization: organization) }

              it "does not allow accepted actions with unexpected context" do
                action = PermissionAction.new(scope: :admin, action: :update, subject: :process)
                permissions = DepartmentAdmin::Permissions.new(user, action, process:)
                expect { permissions.permissions.allowed? }.to raise_error(Decidim::PermissionAction::PermissionNotSetError)
              end
            end
          end

          context "with the actions menu of processes and assemblies" do
            let(:process) { create(:participatory_process, organization:, department:) }
            let(:assembly) { create(:assembly, organization:, department:) }
            let(:other_process) { create(:participatory_process, organization:) }

            it "allows to share, duplicate and preview" do
              should_allow_action_with_ctx(:admin, :read, :share_token, current_participatory_space: process)
              should_allow_action_with_ctx(:admin, :read, :share_token, current_participatory_space: assembly)
              should_allow_action_with_ctx(:admin, :create, :share_token, current_participatory_space: process)
              should_allow_action_with_ctx(:admin, :update, :share_token, current_participatory_space: process)
              should_allow_action_with_ctx(:admin, :destroy, :share_token, current_participatory_space: process)
              should_allow_action_with_ctx(:admin, :preview, :assembly, assembly:)
              should_allow_action(:admin, :copy, :assembly)
            end

            it "does not allow to share spaces of other departments" do
              permission_action = PermissionAction.new(scope: :admin, action: :read, subject: :share_token)
              permissions = DepartmentAdmin::Permissions.new(user, permission_action, current_participatory_space: other_process)
              expect { permissions.permissions.allowed? }.to raise_error(Decidim::PermissionAction::PermissionNotSetError)
            end
          end

          context "when managing the trash" do
            let(:process) { create(:participatory_process, :unpublished, organization:, department:) }
            let(:assembly) { create(:assembly, :unpublished, organization:, department:) }
            let(:component) { create(:component, :unpublished, participatory_space: process) }
            let(:deleted_process) { create(:participatory_process, :unpublished, organization:, department:, deleted_at: Time.current) }
            let(:other_process) { create(:participatory_process, :unpublished, organization:) }

            def permission_not_set?(action, subject, ctx)
              permission_action = PermissionAction.new(scope: :admin, action:, subject:)
              permissions = DepartmentAdmin::Permissions.new(user, permission_action, ctx)
              expect { permissions.permissions.allowed? }.to raise_error(Decidim::PermissionAction::PermissionNotSetError)
            end

            it "allows to soft delete and see the trash of spaces and components of their department" do
              should_allow_action(:admin, :manage_trash, :process)
              should_allow_action(:admin, :manage_trash, :assembly)
              should_allow_action_with_ctx(:admin, :manage_trash, :component, current_participatory_space: process)
              should_allow_action_with_ctx(:admin, :soft_delete, :process, trashable_deleted_resource: process)
              should_allow_action_with_ctx(:admin, :soft_delete, :assembly, trashable_deleted_resource: assembly)
              should_allow_action_with_ctx(:admin, :soft_delete, :component, trashable_deleted_resource: component)
              should_allow_action_with_ctx(:admin, :restore, :process, trashable_deleted_resource: deleted_process)
            end

            it "allows the subject used by the processes controller" do
              should_allow_action(:admin, :manage_trash, :participatory_process)
              should_allow_action_with_ctx(:admin, :soft_delete, :participatory_process, trashable_deleted_resource: process)
              should_allow_action_with_ctx(:admin, :restore, :participatory_process, trashable_deleted_resource: deleted_process)
              permission_not_set?(:soft_delete, :participatory_process, trashable_deleted_resource: other_process)
            end

            context "with conferences" do
              let(:other_department) { create(:department, organization:) }
              let(:conference) { create(:conference, :unpublished, organization:, department: other_department) }
              let(:deleted_conference) { create(:conference, :unpublished, organization:, department: other_department, deleted_at: Time.current) }

              it "allows to soft delete and restore conferences of any department" do
                should_allow_action(:admin, :manage_trash, :conference)
                should_allow_action_with_ctx(:admin, :soft_delete, :conference, trashable_deleted_resource: conference)
                should_allow_action_with_ctx(:admin, :restore, :conference, trashable_deleted_resource: deleted_conference)
                permission_not_set?(:soft_delete, :conference, trashable_deleted_resource: deleted_conference)
                permission_not_set?(:restore, :conference, trashable_deleted_resource: conference)
              end
            end

            it "shows the link to the deleted spaces in the index" do
              should_allow_action_with_ctx(:admin, :read, :process, trashable_deleted_resource: Decidim::ParticipatoryProcess.all)
              should_allow_action_with_ctx(:admin, :read, :assembly, trashable_deleted_resource: Decidim::Assembly.all)
              should_allow_action_with_ctx(:admin, :read, :conference, trashable_deleted_resource: Decidim::Conference.all)
            end

            it "does not allow to read a single space through the trash link check" do
              permission_not_set?(:read, :process, trashable_deleted_resource: other_process)
            end

            it "does not allow to soft delete deleted resources nor restore non deleted ones" do
              permission_not_set?(:soft_delete, :process, trashable_deleted_resource: deleted_process)
              permission_not_set?(:restore, :process, trashable_deleted_resource: process)
            end

            it "does not allow to soft delete spaces from other departments" do
              permission_not_set?(:soft_delete, :process, trashable_deleted_resource: other_process)
              permission_not_set?(:manage_trash, :component, current_participatory_space: other_process)
            end
          end

          # context "when acction is allowed and context is component" do
          # context "when component has same area as department_admin" do
          # TODO: complete the test implementation
          # let(:process) { create(:participatory_process, organization: area.organization, area: area) }
          # let(:component) { create(:survey, participatory_space: process) }

          # it "should allow accepted actions" # do
          #   should_allow_action(:admin, :read, :component)
          #   should_allow_action(:admin, :create, :component)
          #   should_allow_action_with_ctx(:admin, :export, :component_data, current_participatory_space: process)
          # end
          # end
          # end
        end
      end
    end
  end
end
