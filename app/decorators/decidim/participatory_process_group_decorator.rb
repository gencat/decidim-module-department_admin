# frozen_string_literal: true

#
# This decorator adds required associations between Decidim::ParticipatoryProcess and Departaments.
#
#
require_dependency 'decidim/participatory_process_group'
Decidim::ParticipatoryProcessGroup.class_eval do
  has_many  :participatory_process,
            class_name: 'ParticipatoryProcess',
            foreign_key: 'decidim_participatory_process_group_id'

end
