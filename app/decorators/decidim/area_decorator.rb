# frozen_string_literal: true

require_dependency "decidim/area"

Decidim::Area.class_eval do
  before_destroy :abort_if_department_admins

  has_and_belongs_to_many :users,
                          join_table: :department_admin_areas,
                          foreign_key: :decidim_area_id,
                          association_foreign_key: :decidim_user_id,
                          validate: false

  has_many :participatory_process,
           class_name: "ParticipatoryProcess",
           foreign_key: "decidim_department_id"

  has_many :assemblies,
           class_name: "Assemblies",
           foreign_key: "decidim_area_id"

  if defined?(Decidim::Conferences)
    has_many :conferences,
             class_name: "Conferences",
             foreign_key: "decidim_area_id"
  end

  def has_department_admins?
    Decidim::User.where(organization: organization).any? do |u|
      u.areas.exists?(id)
    end
  end

  def abort_if_department_admins
    throw(:abort) if has_department_admins?
  end
end
