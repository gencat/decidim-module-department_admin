# frozen_string_literal: true

module Decidim::ParticipatoryProcesses::ParticipatoryProcessPresenterDecorator
  def self.decorate
    Decidim::ParticipatoryProcesses::ParticipatoryProcessPresenter.class_eval do
      def department_name
        return if process.decidim_department_admin_department_id.blank?

        Decidim::DepartmentAdmin::DepartmentPresenter.new(process.department).translated_name
      end
    end
  end
end

Decidim::ParticipatoryProcesses::ParticipatoryProcessPresenterDecorator.decorate
