# frozen_string_literal: true

module Decidim::Conferences::Admin::ConferencesControllerDecorator
  #
  # This decorator adds the capability to the controller to query conferences
  # filtering by User role `department_admin`.
  #
  def self.decorate
    return unless Decidim::DepartmentAdmin.conferences_defined?

    Decidim::Conferences::Admin::ConferencesController.class_eval do
      private

      alias_method :original_collection, :collection

      def collection
        @collection ||= if current_user.admin?
                          original_collection
                        else
                          ::Decidim::Conferences::ConferencesWithUserRole.for(current_user)
                        end
      end
    end
  end
end

Decidim::Conferences::Admin::ConferencesControllerDecorator.decorate
