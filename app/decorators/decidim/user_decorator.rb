# frozen_string_literal: true

#
# This decorator adds required associations between Decidim::User and Area.
#

require_dependency 'decidim/user'
Decidim::User.class_eval do
  has_and_belongs_to_many :areas,
                          join_table: :department_admin_areas,
                          foreign_key: :decidim_user_id,
                          association_foreign_key: :decidim_area_id,
                          validate: false

  has_and_belongs_to_many :participatory_process,
                          join_table: :decidim_participatory_process_user_roles,
                          foreign_key: :decidim_user_id,
                          association_foreign_key: :decidim_participatory_process_id,
                          validate: false

  has_and_belongs_to_many :assembly,
                          join_table: :decidim_assembly_user_roles,
                          foreign_key: :decidim_user_id,
                          association_foreign_key: :decidim_assembly_id,
                          validate: false

  scope :admins, -> { where(admin: true) }
  scope :user_managers, -> { where(roles: ["user_manager"]) }
  scope :department_admins, -> { where(roles: ["department_admin"]) }
  scope :process_admins, -> { where(roles: ["process_admin"]) }
  scope :assembly_admins, -> { where(roles: ["assembly_admin"]) }

  def department_admin?
    role?('department_admin')
  end

  def process_admin?
    role?('process_admin')
  end

  def assembly_admin?
    role?('assembly_admin')
  end
end
