# frozen_string_literal: true

# require_dependency 'decidim/participatory_processes/admin/application_controller'

# Decidim::ParticipatoryProcesses::Admin::ApplicationController.class_eval do

#   alias_method :old_permission_class_chain, :permission_class_chain

#   def permission_class_chain
#     raise 'OLIVER!'
#     @chain ||= begin
#       chain= old_permission_class_chain
#       chain.unshift(Decidim::DepartmentAdmin::Permissions)
#       chain
#     end
#   end
# end

require_dependency 'decidim/participatory_processes/admin/concerns/participatory_process_admin'
Decidim::ParticipatoryProcesses::Admin::Concerns::ParticipatoryProcessAdmin.class_eval do

  private

  alias_method :old_permission_class_chain, :permission_class_chain

  def permission_class_chain
    raise 'OLIVER!'
    @chain ||= begin
      chain= old_permission_class_chain
      chain.unshift(Decidim::DepartmentAdmin::Permissions)
      chain
    end
  end  
end