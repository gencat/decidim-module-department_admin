# frozen_string_literal: true

module Decidim::Assemblies::PermissionsDecorator
  def self.decorate
    Decidim::Assemblies::Permissions.class_eval do
      # Intercept the `has_manageable_assemblies?` method
      # always returns true if the user is a department_admin. Otherwise delegates to the original method.
      # This is a fix to avoid permissions crashing when there are no assemblies with the user's area.
      alias_method :original_has_manageable_assemblies?, :has_manageable_assemblies?
      alias_method :original_permissions, :permissions

      # rubocop: disable Lint/UnusedMethodArgument
      def has_manageable_assemblies?(role: :any)
        return false unless user

        user.department_admin? || original_has_manageable_assemblies?
      end
      # rubocop: enable Lint/UnusedMethodArgument

      def permissions
        return original_permissions unless department_admin_update_assembly_action?

        allow!
        permission_action
      end

      private

      # Only assemblies of the user's departments.
      def department_admin_update_assembly_action?
        return false unless user&.department_admin?
        return false unless permission_action.matches?(:admin, :update, :assembly)

        assembly.is_a?(Decidim::Assembly) && user.departments.include?(assembly.department)
      end
    end
  end
end

Decidim::Assemblies::PermissionsDecorator.decorate
