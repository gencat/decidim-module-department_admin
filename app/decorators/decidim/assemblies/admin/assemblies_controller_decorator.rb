# frozen_string_literal: true

#
# This decorator adds the capability to the controller to query assemblies
# filtering by User role `department_admin`.
#
Decidim::Assemblies::Admin::AssembliesController.class_eval do
  private

  alias_method :original_organization_assemblies, :organization_assemblies

  def organization_assemblies
    if current_user.admin?
      query = original_organization_assemblies
    else
      query= ::Decidim::Assemblies::AssembliesWithUserRole.for(current_user)
    end
  end
end
