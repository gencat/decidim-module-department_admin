# frozen_string_literal: true

# Intercepts the `call` method and forces the Area of the user if it is a
# department_admin user.
module Decidim::Conferences::UpdateConferenceDecorator
  def self.decorate
    return unless Decidim::DepartmentAdmin.conferences_defined?

    Decidim::Conferences::Admin::UpdateConference.class_eval do
      alias_method :original_call, :call

      def call
        author = form.current_user
        form.area_id = author.areas.first.id if author.department_admin?
        original_call
      end
    end
  end
end

Decidim::Conferences::UpdateConferenceDecorator.decorate
