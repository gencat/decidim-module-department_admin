# frozen_string_literal: true

#
# This decorator adds the capability to the controller to query assemblies
# filtering by User role `department_admin`.
#
Decidim::Assemblies::Admin::AssembliesController.class_eval do
  private

  alias_method :original_organization_assemblies, :collection

  def collection
    if current_user.admin?
      original_organization_assemblies
    else
      ::Decidim::Assemblies::AssembliesWithUserRole.for(current_user)
    end
  end
end
