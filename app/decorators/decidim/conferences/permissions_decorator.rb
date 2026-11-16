# frozen_string_literal: true

module Decidim::Conferences::PermissionsDecorator
  def self.decorate
    return unless Decidim::DepartmentAdmin.conferences_defined?

    Decidim::Conferences::Permissions.class_eval do
      # Intercept the `has_manageable_conferences?` method
      # always returns true if the user is a department_admin. Otherwise delegates to the original method.
      # This is a fix to avoid permissions crashing when there are no conferences with the user's area.
      alias_method :original_has_manageable_conferences?, :has_manageable_conferences?
      alias_method :original_permissions, :permissions

      # rubocop: disable Lint/UnusedMethodArgument
      def has_manageable_conferences?(role: :any)
        return false unless user

        user.department_admin? || original_has_manageable_conferences?
      end
      # rubocop: enable Lint/UnusedMethodArgument

      def permissions
        return original_permissions unless department_admin_update_conference_action?

        allow!
        permission_action
      end

      private

      # Conferences are not restricted by department, as in Decidim::DepartmentAdmin::Permissions.
      def department_admin_update_conference_action?
        return false unless user&.department_admin?
        return false unless permission_action.matches?(:admin, :update, :conference)

        conference.is_a?(Decidim::Conference)
      end
    end
  end
end

Decidim::Conferences::PermissionsDecorator.decorate
