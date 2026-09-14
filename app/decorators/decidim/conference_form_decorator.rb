# frozen_string_literal: true

module Decidim::ConferenceFormDecorator
  #
  # This decorator adds the attribute decidim_department_admin_department_id to
  # the ConferenceForm and extends it with utility methods for the view and command.
  #
  def self.decorate
    return unless Decidim::DepartmentAdmin.conferences_defined?

    Decidim::Conferences::Admin::ConferenceForm.class_eval do
      attribute :decidim_department_admin_department_id, Integer

      validates :department, presence: true, if: proc { |object| object.decidim_department_admin_department_id.present? }

      def department
        @department ||= Decidim::DepartmentAdmin::Department.find_by(id: decidim_department_admin_department_id)
      end
    end
  end
end

Decidim::ConferenceFormDecorator.decorate
