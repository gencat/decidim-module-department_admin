# frozen_string_literal: true

#
# This decorator adds the capability to the controller to query conferences
# filtering by User role `department_admin`.
#
if Decidim::DepartmentAdmin.conferences_defined?
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
