# frozen_string_literal: true

module Decidim::Assemblies::Admin::AssemblyFormDecorator
  def self.decorate
    Decidim::Assemblies::Admin::AssemblyForm.class_eval do
      attribute :decidim_department_admin_department_id, Integer
    end
  end
end

Decidim::Assemblies::Admin::AssemblyFormDecorator.decorate
