# frozen_string_literal: true

module Decidim::Assemblies::UpdateAssemblyDecorator
  # Forces the Area of the user if it is a department_admin user.
  def self.decorate
    Decidim::Assemblies::Admin::UpdateAssembly.class_eval do
      def run_before_hooks
        author = form.current_user
        resource.decidim_area_id = author.areas.first.id if author.department_admin?
      end
    end
  end
end

Decidim::Assemblies::UpdateAssemblyDecorator.decorate
