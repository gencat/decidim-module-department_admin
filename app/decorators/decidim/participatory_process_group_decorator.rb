# frozen_string_literal: true

module Decidim::ParticipatoryProcessGroupDecorator
  #
  # This decorator adds required associations between Decidim::ParticipatoryProcess and Departaments.
  #
  def self.decorate
    require_dependency "decidim/participatory_process_group"
    Decidim::ParticipatoryProcessGroup.class_eval do
      has_many :participatory_process,
               class_name: "ParticipatoryProcess",
               foreign_key: "decidim_participatory_process_group_id"
    end
  end
end

Decidim::ParticipatoryProcessGroupDecorator.decorate
