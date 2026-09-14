# frozen_string_literal: true

module Decidim::InviteUserFormDecorator
  #
  # This decorator adds the attribute department_id to the InviteUserForm and
  # extends it with utility methods for the view and command.
  #
  def self.decorate
    Decidim::InviteUserForm.class_eval do
      attribute :decidim_department_admin_department_id, Integer

      alias_method :original_roles_method, :available_roles_for_select

      def available_roles_for_select
        if current_user.department_admin?
          Decidim::User::Roles.all.select { |n| n == "department_admin" }.map do |role|
            [
              I18n.t("models.user.fields.roles.#{role}", scope: "decidim.admin"),
              role,
            ]
          end
        else
          original_roles_method
        end
      end

      # called from the view
      def available_departments_for_select
        if current_user.department_admin?
          current_user.departments.map { |d| [d.translated_name, d.id] }
        else
          Decidim::DepartmentAdmin::Department
            .where(decidim_organization_id: current_organization.id)
            .map { |d| [d.translated_name, d.id] }
        end
      end

      # called from the command
      # returns the selected Decidim::DepartmentAdmin::Department instance.
      def selected_department
        Decidim::DepartmentAdmin::Department.find_by(id: decidim_department_admin_department_id)
      end
    end
  end
end

Decidim::InviteUserFormDecorator.decorate
