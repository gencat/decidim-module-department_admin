# frozen_string_literal: true

#
# This decorator adds the capability to query participatory_processes
# filtering by User role `department_admin`.
#
Decidim::Assemblies::AssembliesWithUserRole.class_eval do

  private

  alias_method :assembly_ids_by_assemblies_user_table, :assembly_ids

  def assembly_ids
    if user&.department_admin?
      Decidim::Assembly.
        where('decidim_area_id' => user.areas.pluck(:id))
    else
      assembly_ids_by_assemblies_user_table
    end
  end
end