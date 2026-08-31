# frozen_string_literal: true

module Decidim::Assemblies::CreateAssemblyDecorator
  # Forces the Area of the user if it is a department_admin user.
  def self.decorate
    Decidim::Assemblies::Admin::CreateAssembly.class_eval do
      fetch_form_attributes :title, :subtitle, :weight, :slug, :hashtag, :description, :short_description,
                            :promoted, :taxonomizations, :parent, :announcement, :organization,
                            :private_space, :developer_group, :local_area, :target, :participatory_scope,
                            :participatory_structure, :meta_scope, :purpose_of_action,
                            :composition, :creation_date, :created_by, :created_by_other,
                            :duration, :included_at, :closing_date, :closing_date_reason, :internal_organisation,
                            :is_transparent, :special_features, :twitter_handler, :facebook_handler,
                            :instagram_handler, :youtube_handler, :github_handler, :decidim_department_admin_department_id
      alias_method :run_after_hooks_original, :run_after_hooks

      def run_after_hooks
        run_after_hooks_original

        author = form.current_user
        if author.department_admin?
          resource.update(decidim_department_admin_department_id: author.departments.first.id)
        elsif form.try(:decidim_department_admin_department_id).present?
          resource.update(decidim_department_admin_department_id: form.decidim_department_admin_department_id)
        end
      end
    end
  end
end

Decidim::Assemblies::CreateAssemblyDecorator.decorate
