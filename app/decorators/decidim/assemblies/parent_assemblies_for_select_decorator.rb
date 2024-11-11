# frozen_string_literal: true

module Decidim::Assemblies::ParentAssembliesForSelectDecorator
  # This decorator adds current_user as an argument to be able to check
  # it's department in the query and filter the assemblies by area.
  def self.decorate
    Decidim::Assemblies::ParentAssembliesForSelect.class_eval do
      # Syntactic sugar to initialize the class and return the queried objects.
      def self.for(organization, assembly, current_user = nil)
        new(organization, assembly, current_user).query
      end

      # Initializes the class.
      def initialize(organization, assembly, current_user)
        @organization = organization
        @assembly = assembly
        @current_user = current_user
      end

      # Finds the available assemblies
      #
      # Returns an ActiveRecord::Relation.
      def query
        available_assemblies = if @current_user.present? && @current_user.department_admin?
                                 Decidim::Assembly.where(area: @current_user.areas).where.not(id: @assembly)
                               else
                                 Decidim::Assembly.where(organization: @organization).where.not(id: @assembly)
                               end

        return available_assemblies if @assembly.blank?

        available_assemblies.where.not(id: descendant_ids)
      end
    end
  end
end

Decidim::Assemblies::ParentAssembliesForSelectDecorator.decorate
