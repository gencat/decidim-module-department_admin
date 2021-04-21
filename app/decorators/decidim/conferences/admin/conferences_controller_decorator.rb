# frozen_string_literal: true

#
# This decorator adds the capability to the controller to query conferences
# filtering by User role `department_admin`.
#
Decidim::Conferences::Admin::ConferencesController.class_eval do
  private

  alias_method :original_organization_conferences, :collection

  def collection
    @collection ||= if current_user.admin?
                      original_organization_conferences
                    else
                      ::Decidim::Conferences::ConferencesWithUserRole.for(current_user)
                    end
  end
end
