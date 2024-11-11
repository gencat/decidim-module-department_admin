# frozen_string_literal: true

module Decidim::ParticipatoryProcesses::CreateParticipatoryProcessDecorator
  # Intercepts the `call` method and forces the Area of the user if it is a
  # department_admin user.
  def self.decorate
    Decidim::ParticipatoryProcesses::Admin::CreateParticipatoryProcess.class_eval do
      alias_method :original_call, :call

      def call
        author = form.current_user
        form.area_id = author.areas.first.id if author.department_admin?
        original_call
      end
    end
  end
end

Decidim::ParticipatoryProcesses::CreateParticipatoryProcessDecorator.decorate
