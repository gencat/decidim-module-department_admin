# frozen_string_literal: true

module Decidim::ParticipatoryProcessesWithUserRoleDecorator
  #
  # This decorator adds the capability to query participatory_processes
  # filtering by User role `department_admin`.
  #
  def self.decorate
    Decidim::ParticipatoryProcessesWithUserRole.class_eval do
      private

      alias_method :process_ids_by_process_user_table, :process_ids

      def process_ids
        ids = [process_ids_by_process_user_table]
        if user&.department_admin?
          ids << ::Decidim::ParticipatoryProcess
                 .where("decidim_area_id" => user.areas.pluck(:id))
        end

        ::Decidim::ParticipatoryProcess.where(id: ids.flatten.uniq)
      end
    end
  end
end

Decidim::ParticipatoryProcessesWithUserRoleDecorator.decorate
