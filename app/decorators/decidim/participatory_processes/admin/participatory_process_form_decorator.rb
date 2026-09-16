# frozen_string_literal: true

module Decidim::ParticipatoryProcesses::Admin::ParticipatoryProcessFormDecorator
  def self.decorate
    Decidim::ParticipatoryProcesses::Admin::ParticipatoryProcessForm.class_eval do
      attribute :decidim_department_admin_department_id, Integer
    end
  end
end

Decidim::ParticipatoryProcesses::Admin::ParticipatoryProcessFormDecorator.decorate
