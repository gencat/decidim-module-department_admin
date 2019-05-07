# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    class ParticipatorySpacePermissions < Decidim::DepartmentAdmin::Permissions
      def initialize(*)
        self.class.delegate_chain= [Decidim::ParticipatoryProcesses::Permissions]
        super
      end
    end
  end
end
