# frozen_string_literal: true

module Decidim::Assemblies::CreateAssemblyDecorator
  # Intercepts the `call` method and forces the Area of the user if it is a
  # department_admin user.
  def self.decorate
    Decidim::Assemblies::Admin::CreateAssembly.class_eval do
      alias_method :original_call, :call

      def call
        author = form.current_user
        form.area_id = author.areas.first.id if author.department_admin?
        original_call
      end
    end
  end
end

::Decidim::Assemblies::CreateAssemblyDecorator.decorate
