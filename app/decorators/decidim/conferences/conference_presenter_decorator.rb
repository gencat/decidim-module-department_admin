# frozen_string_literal: true

module Decidim::Conferences::ConferencePresenterDecorator
  def self.decorate
    return unless Decidim::DepartmentAdmin.conferences_defined?

    Decidim::Conferences::ConferencePresenter.class_eval do
      def department_name
        return if conference.decidim_department_admin_department_id.blank?

        Decidim::DepartmentAdmin::DepartmentPresenter.new(conference.department).translated_name
      end
    end
  end
end

Decidim::Conferences::ConferencePresenterDecorator.decorate
