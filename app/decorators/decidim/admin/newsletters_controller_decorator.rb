# frozen_string_literal: true

require_dependency "decidim/admin/newsletters_controller"

module Decidim::Admin::NewslettersControllerDecorator
  # Sort Admins by role and department
  def self.decorate
    ::Decidim::Admin::NewslettersController.class_eval do
      alias_method :original_collection, :collection

      private

      def collection
        return original_collection unless current_user.department_admin?

        @collection ||= Decidim::Newsletter.where(organization: current_organization)
                                           .joins(author: :departments)
                                           .where(department_admin_departments: { id: current_user_departments.pluck(:id) })
      end

      def current_user_departments
        return unless current_user.department_admin?

        current_user.departments
      end
    end
  end
end

Decidim::Admin::NewslettersControllerDecorator.decorate
