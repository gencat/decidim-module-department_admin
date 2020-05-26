# frozen_string_literal: true

#
# This decorator adds the capability to the controller to query processes
# filtering by User role `department_admin`.
#
Decidim::ParticipatoryProcesses::Admin::ParticipatoryProcessesController.class_eval do
  private

  alias_method :original_organization_processes, :collection

  def collection
    if current_user.admin?
      query = original_organization_processes
    else
      query= ::Decidim::ParticipatoryProcessesWithUserRole.for(current_user)
    end
  end
end
