# frozen_string_literal: true

#
# This decorator extends Decidim::User with:
# - the new role in ROLES, and 
# - adds required associations between User and Area.
#

Decidim::User::ROLES = %w(admin department_admin user_manager).freeze

require_dependency 'decidim/user'
Decidim::User.class_eval do
  has_and_belongs_to_many :areas,
    join_table: :department_admin_areas,
    foreign_key: :decidim_user_id,
    association_foreign_key: :decidim_area_id,
    validate: false
end

require_dependency 'decidim/area'
Decidim::Area.class_eval do
  has_and_belongs_to_many :users,
    join_table: :department_admin_areas,
    foreign_key: :decidim_area_id,
    association_foreign_key: :decidim_user_id,
    validate: false
end
