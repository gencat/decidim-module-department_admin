# frozen_string_literal: true

#
# This decorator adds the capability to the controller to query assemblies
# filtering by User role `department_admin`.
#
Decidim::Assemblies::Admin::AssembliesController.class_eval do
  private

  alias_method :original_organization_assemblies, :collection

  def collection
    query = original_organization_assemblies
    query = query.where(decidim_area_id: current_user.areas.pluck(:id)) if current_user&.department_admin?
    query
  end
end
