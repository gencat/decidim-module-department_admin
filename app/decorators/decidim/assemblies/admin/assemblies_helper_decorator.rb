# frozen_string_literal: true

module Decidim::Assemblies::Admin::AssembliesHelperDecorator
  #
  # This decorator sends current_user as argument when it's a department admin.
  #
  def self.decorate
    Decidim::Assemblies::Admin::AssembliesHelper.class_eval do
      alias_method :parent_assemblies_options_original, :parent_assemblies_options

      # Public: select options representing a collection of Assemblies that
      # can be selected as parent assemblies for another assembly; to be used in forms.
      def parent_assemblies_options
        if current_user.department_admin?
          options = []
          root_assemblies ||= Decidim::Assemblies::ParentAssembliesForSelect.for(current_organization, current_assembly, current_user)

          root_assemblies.each do |assembly|
            build_assembly_options(assembly, options)
          end
        else
          parent_assemblies_options_original
        end
      end
    end
  end
end

Decidim::Assemblies::Admin::AssembliesHelperDecorator.decorate
