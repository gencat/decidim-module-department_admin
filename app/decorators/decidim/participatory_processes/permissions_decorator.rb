# frozen_string_literal: true

module Decidim::ParticipatoryProcesses::PermissionsDecorator
  def self.decorate
    Decidim::ParticipatoryProcesses::Permissions.class_eval do
      # Intercept the `has_manageable_processes?` method
      # always returns true if the user is a department_admin. Otherwise delegates to the original method.
      # This is a fix to avoid permissions crashing when there are no processes with the user's area.
      alias_method :original_has_manageable_processes?, :has_manageable_processes?
      alias_method :original_permissions, :permissions

      # rubocop: disable Lint/UnusedMethodArgument
      def has_manageable_processes?(role: :any)
        return false unless user

        user.department_admin? || original_has_manageable_processes?
      end
      # rubocop: enable Lint/UnusedMethodArgument

      def permissions
        return original_permissions unless department_admin_update_process_action?

        allow!
        permission_action
      end

      private

      # Only processes of the user's departments.
      def department_admin_update_process_action?
        return false unless user&.department_admin?
        return false unless permission_action.matches?(:admin, :update, :process)

        process.is_a?(Decidim::ParticipatoryProcess) && user.departments.include?(process.department)
      end
    end
  end
end

Decidim::ParticipatoryProcesses::PermissionsDecorator.decorate
