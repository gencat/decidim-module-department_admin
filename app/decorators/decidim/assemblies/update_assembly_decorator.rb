# frozen_string_literal: true

module Decidim::Assemblies::UpdateAssemblyDecorator
  # Forces the Area of the user if it is a department_admin user.
  def self.decorate
    Decidim::Assemblies::Admin::UpdateAssembly.class_eval do
              fetch_form_attributes :title, :subtitle, :slug, :hashtag, :promoted, :description, :short_description,
                              :taxonomizations, :parent, :private_space, :developer_group, :local_area,
                              :target, :participatory_scope, :participatory_structure, :meta_scope,
                              :purpose_of_action, :composition, :creation_date, :created_by,
                              :created_by_other, :duration, :included_at, :closing_date, :closing_date_reason,
                              :internal_organisation, :is_transparent, :special_features, :twitter_handler, :announcement,
                              :facebook_handler, :instagram_handler, :youtube_handler, :github_handler, :weight, :decidim_department_admin_department_id
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

Decidim::Assemblies::UpdateAssemblyDecorator.decorate
