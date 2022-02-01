# frozen_string_literal: true

#
# This decorator sends current_user as argument when it's a department admin.
#
Decidim::Assemblies::Admin::AssembliesHelper.class_eval do
  alias_method :parent_assemblies_for_select_original, :parent_assemblies_for_select

  # Public: A collection of Assemblies that can be selected as parent
  # assemblies for another assembly; to be used in forms.
  def parent_assemblies_for_select
    if current_user.department_admin?
      @parent_assemblies_for_select ||= Decidim::Assemblies::ParentAssembliesForSelect.for(current_organization, current_assembly, current_user)
    else
      parent_assemblies_for_select_original
    end
  end
end
