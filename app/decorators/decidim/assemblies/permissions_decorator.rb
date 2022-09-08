# frozen_string_literal: true

module Decidim::Assemblies::PermissionsDecorator
  def self.decorate
    Decidim::Assemblies::Permissions.class_eval do
      # Intercept the `has_manageable_assemblies?` method
      # always returns true if the user is a department_admin. Otherwise delegates to the original method.
      # This is a fix to avoid permissions crashing when there are no assemblies with the user's area.
      alias_method :original_has_manageable_assemblies?, :has_manageable_assemblies?

      # rubocop: disable Lint/UnusedMethodArgument
      def has_manageable_assemblies?(role: :any)
        return unless user

        user.department_admin? || original_has_manageable_assemblies?
      end
      # rubocop: enable Lint/UnusedMethodArgument
    end
  end
end

::Decidim::Assemblies::PermissionsDecorator.decorate
