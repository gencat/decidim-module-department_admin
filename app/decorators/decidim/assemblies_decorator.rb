# frozen_string_literal: true

#
# This decorator adds required associations between Decidim::ParticipatoryProcess and Departaments.
#
#
require_dependency 'decidim/assembly'
Decidim::Assembly.class_eval do
  belongs_to  :areas,
              class_name: 'Areas',
              foreign_key: 'decidim_area_id'


  has_and_belongs_to_many :users,
                          join_table: :decidim_assembly_user_roles,
                          foreign_key: :decidim_assembly_id,
                          association_foreign_key: :decidim_user_id,
                          validate: false
end
