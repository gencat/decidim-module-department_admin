# frozen_string_literal: true

module Decidim::ParticipatoryProcessDecorator
  #
  # This decorator adds required associations between Decidim::ParticipatoryProcess and Departaments.
  #
  #
  def self.decorate
    require_dependency "decidim/participatory_process"
    Decidim::ParticipatoryProcess.class_eval do
      has_and_belongs_to_many :users_with_any_role,
                              class_name: "Decidim::User",
                              join_table: :decidim_participatory_process_user_roles,
                              foreign_key: :decidim_participatory_process_id,
                              association_foreign_key: :decidim_user_id,
                              validate: false
    end
  end
end

::Decidim::ParticipatoryProcessDecorator.decorate
