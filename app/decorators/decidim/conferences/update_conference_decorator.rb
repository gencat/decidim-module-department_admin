# frozen_string_literal: true

# Forces the Area of the user if it is a department_admin user.
module Decidim::Conferences::UpdateConferenceDecorator
  def self.decorate
    return unless Decidim::DepartmentAdmin.conferences_defined?

    Decidim::Conferences::Admin::UpdateConference.class_eval do
      def run_before_hooks
        author = form.current_user
        resource.decidim_area_id = author.areas.first.id if author.department_admin?
      end
    end
  end
end

Decidim::Conferences::UpdateConferenceDecorator.decorate
