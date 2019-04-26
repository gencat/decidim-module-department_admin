# frozen_string_literal: true

#
# This decorator adds the capability to the controller to query assemblies
# filtering by User role `department_admin`.
#
Decidim::Assemblies::Admin::AssembliesController.class_eval do

  private

  alias_method :original_organization_assemblies, :organization_assemblies

  def organization_assemblies
    query= original_organization_assemblies
    if current_user&.department_admin?
      query= query.where('decidim_area_id' => current_user.areas.pluck(:id))
    end
    query
  end
end