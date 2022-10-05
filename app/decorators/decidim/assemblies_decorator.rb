# frozen_string_literal: true

require_dependency "decidim/assembly"

module Decidim::AssembliesDecorator
  #
  # This decorator adds required associations between Decidim::ParticipatoryProcess and Departaments.
  #
  def self.decorate
    Decidim::Assembly.class_eval do
      has_and_belongs_to_many :users_with_any_role,
                              class_name: "Decidim::User",
                              join_table: :decidim_assembly_user_roles,
                              foreign_key: :decidim_assembly_id,
                              association_foreign_key: :decidim_user_id,
                              validate: false
    end
  end
end

::Decidim::AssembliesDecorator.decorate
