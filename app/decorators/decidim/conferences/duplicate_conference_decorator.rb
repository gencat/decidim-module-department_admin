# frozen_string_literal: true

module Decidim::Conferences::DuplicateConferenceDecorator
  # Keeps the Department of the original conference in the duplicated one.
  def self.decorate
    return unless Decidim::DepartmentAdmin.conferences_defined?

    Decidim::Conferences::Admin::DuplicateConference.class_eval do
      alias_method :original_duplicate_conference, :duplicate_conference

      private

      def duplicate_conference
        original_duplicate_conference
        @duplicated_conference.update!(decidim_department_admin_department_id: @conference.decidim_department_admin_department_id)
      end
    end
  end
end

Decidim::Conferences::DuplicateConferenceDecorator.decorate
