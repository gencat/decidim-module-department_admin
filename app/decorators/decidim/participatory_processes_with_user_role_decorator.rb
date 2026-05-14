# frozen_string_literal: true

module Decidim::ParticipatoryProcessesWithUserRoleDecorator
  #
  # This decorator adds the capability to query participatory_processes
  # filtering by User role `department_admin`.
  #
  def self.decorate
    Decidim::ParticipatoryProcessesWithUserRole.class_eval do
      private

      alias_method :process_ids_original, :process_ids

      def process_ids
        ids = [process_ids_original]
        if user&.department_admin?
          ids << ::Decidim::ParticipatoryProcess
                 .where(decidim_department_admin_department_id: user.departments.pluck(:id))
        end

        ::Decidim::ParticipatoryProcess.where(id: ids.flatten.uniq)
      end
    end
  end
end

Decidim::ParticipatoryProcessesWithUserRoleDecorator.decorate
