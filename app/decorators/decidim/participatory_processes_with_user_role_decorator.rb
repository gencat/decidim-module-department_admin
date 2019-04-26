# frozen_string_literal: true

#
# This decorator adds the capability to query participatory_processes
# filtering by User role `department_admin`.
#
Decidim::ParticipatoryProcessesWithUserRole.class_eval do

  private

  alias_method :process_ids_by_process_user_table, :process_ids

  def process_ids
    if user&.department_admin?
      Decidim::ParticipatoryProcess.
        where('decidim_area_id' => user.areas.pluck(:id))
    else
      process_ids_by_process_user_table
    end
  end
end