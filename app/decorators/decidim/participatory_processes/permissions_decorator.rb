# frozen_string_literal: true

module Decidim::ParticipatoryProcesses::PermissionsDecorator
  def self.decorate
    Decidim::ParticipatoryProcesses::Permissions.class_eval do
      # Intercept the `has_manageable_processes?` method
      # always returns true if the user is a department_admin. Otherwise delegates to the original method.
      # This is a fix to avoid permissions crashing when there are no processes with the user's area.
      alias_method :original_has_manageable_processes?, :has_manageable_processes?

      # rubocop: disable Lint/UnusedMethodArgument
      def has_manageable_processes?(role: :any)
        return unless user

        user.department_admin? || original_has_manageable_processes?
      end
      # rubocop: enable Lint/UnusedMethodArgument
    end
  end
end

::Decidim::ParticipatoryProcesses::PermissionsDecorator.decorate
