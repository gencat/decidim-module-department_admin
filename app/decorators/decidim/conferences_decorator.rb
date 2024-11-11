# frozen_string_literal: true

module Decidim::ConferencesDecorator
  #
  # This decorator adds required associations between Decidim::Conference and Area.
  #
  def self.decorate
    return unless Decidim::DepartmentAdmin.conferences_defined?

    require_dependency "decidim/conference"
    Decidim::Conference.class_eval do
      belongs_to :area,
                 foreign_key: "decidim_area_id",
                 class_name: "Decidim::Area",
                 optional: true

      has_and_belongs_to_many :users_with_any_role,
                              class_name: "Decidim::User",
                              join_table: :decidim_conference_user_roles,
                              foreign_key: :decidim_conference_id,
                              association_foreign_key: :decidim_user_id,
                              validate: false
    end
  end
end

Decidim::ConferencesDecorator.decorate
