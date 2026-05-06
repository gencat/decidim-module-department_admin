# frozen_string_literal: true

module Decidim::Assemblies::CreateAssemblyDecorator
  # Forces the Area of the user if it is a department_admin user.
  def self.decorate
    Decidim::Assemblies::Admin::CreateAssembly.class_eval do
      alias_method :run_after_hooks_original, :run_after_hooks

      def run_after_hooks
        run_after_hooks_original
        author = form.current_user
        resource.update_column(:decidim_area_id, author.areas.first.id) if author.department_admin?
      end
    end
  end
end

Decidim::Assemblies::CreateAssemblyDecorator.decorate
