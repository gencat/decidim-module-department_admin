# frozen_string_literal: true

module Decidim::ConferencesWithUserRoleDecorator
  #
  # This decorator adds the capability to query participatory_processes
  # filtering by User role `department_admin`.
  #
  def self.decorate
    return unless Decidim::DepartmentAdmin.conferences_defined?

    Decidim::Conferences::ConferencesWithUserRole.class_eval do
      private

      alias_method :conference_ids_original, :conference_ids

      def conference_ids
        ids = [conference_ids_original]
        ids << ::Decidim::Conference.with_deleted.pluck(:id) if user&.department_admin?
        ids.flatten.uniq
      end
    end
  end
end

Decidim::ConferencesWithUserRoleDecorator.decorate
