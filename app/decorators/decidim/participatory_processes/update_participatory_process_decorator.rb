# frozen_string_literal: true

module Decidim::ParticipatoryProcesses::UpdateParticipatoryProcessDecorator
  # Forces the Area of the user if it is a department_admin user.
  def self.decorate
    Decidim::ParticipatoryProcesses::Admin::UpdateParticipatoryProcess.class_eval do
      def run_before_hooks
        author = form.current_user
        form.area_id = author.areas.first.id if author.department_admin?
      end
    end
  end
end

Decidim::ParticipatoryProcesses::UpdateParticipatoryProcessDecorator.decorate
