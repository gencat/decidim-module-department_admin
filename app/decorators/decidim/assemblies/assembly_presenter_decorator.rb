# frozen_string_literal: true

module Decidim::Assemblies::AssemblyPresenterDecorator
  def self.decorate
    Decidim::Assemblies::AssemblyPresenter.class_eval do
      def department_name
        return if assembly.decidim_department_admin_department_id.blank?

        Decidim::DepartmentAdmin::DepartmentPresenter.new(assembly.department).translated_name
      end
    end
  end
end

Decidim::Assemblies::AssemblyPresenterDecorator.decorate
