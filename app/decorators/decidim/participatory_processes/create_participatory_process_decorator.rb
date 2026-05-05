# frozen_string_literal: true

module Decidim::ParticipatoryProcesses::CreateParticipatoryProcessDecorator
  # Forces the Area of the user if it is a department_admin user.
  def self.decorate
    Decidim::ParticipatoryProcesses::Admin::CreateParticipatoryProcess.class_eval do
      def run_before_hooks
        author = form.current_user
        form.area_id = author.areas.first.id if author.department_admin?
      end
    end
  end
end

Decidim::ParticipatoryProcesses::CreateParticipatoryProcessDecorator.decorate
