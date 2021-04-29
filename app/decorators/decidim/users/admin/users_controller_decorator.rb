# frozen_string_literal: true

#
# This decorator adds the capability to the controller to query users
# filtering by User role `department_admin`.
#
Decidim::Admin::UsersController.class_eval do
  alias_method :original_method, :collection

  private

  def collection
    if current_user.department_admin?
      @collection ||= current_organization.users_with_any_role
                                          .joins(:areas)
                                          .where("'department_admin' = ANY(roles)")
                                          .where('decidim_areas.id': current_user.areas.pluck(:id))
    else
      original_method
    end
  end
end
