# frozen_string_literal: true

module Decidim::ParticipatoryProcesses::CreateParticipatoryProcessDecorator
  # Forces the Area of the user if it is a department_admin user.
  def self.decorate
    Decidim::ParticipatoryProcesses::Admin::CreateParticipatoryProcess.class_eval do
      fetch_form_attributes :organization, :title, :subtitle, :weight, :slug, :hashtag, :description,
                            :short_description, :promoted, :taxonomizations, :announcement,
                            :private_space, :developer_group, :local_area, :target,
                            :participatory_scope, :participatory_structure, :meta_scope, :start_date, :end_date,
                            :participatory_process_group, :decidim_department_admin_department_id

      protected

      def run_after_hooks
        create_steps
        add_admins_as_followers
        link_related_processes
        Decidim::ContentBlocksCreator.new(resource).create_default!

        author = form.current_user
        if author.department_admin?
          resource.update(:decidim_department_admin_department_id, author.departments.first.id)
        elsif form.try(:decidim_department_admin_department_id).present?
          resource.update(:decidim_department_admin_department_id, form.decidim_department_admin_department_id)
        end
      end
    end
  end
end

Decidim::ParticipatoryProcesses::CreateParticipatoryProcessDecorator.decorate
