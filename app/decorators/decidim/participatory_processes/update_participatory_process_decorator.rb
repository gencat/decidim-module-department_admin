# frozen_string_literal: true

module Decidim::ParticipatoryProcesses::UpdateParticipatoryProcessDecorator
  # Forces the Area of the user if it is a department_admin user.
  def self.decorate
    Decidim::ParticipatoryProcesses::Admin::UpdateParticipatoryProcess.class_eval do
      fetch_form_attributes :title, :subtitle, :weight, :slug, :hashtag, :promoted, :description,
                            :short_description, :taxonomizations,
                            :private_space, :developer_group, :local_area, :target, :participatory_scope,
                            :participatory_structure, :meta_scope, :start_date, :end_date, :participatory_process_group,
                            :announcement, :decidim_department_admin_department_id

      protected

      def run_before_hooks
        author = form.current_user
        if author.department_admin?
          resource.decidim_department_admin_department_id = author.departments.first.id
        elsif form.try(:decidim_department_admin_department_id).present?
          resource.decidim_department_admin_department_id = form.decidim_department_admin_department_id
        end
      end
    end
  end
end

Decidim::ParticipatoryProcesses::UpdateParticipatoryProcessDecorator.decorate
