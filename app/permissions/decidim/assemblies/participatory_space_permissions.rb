# frozen_string_literal: true

module Decidim
  module Assemblies
    class ParticipatorySpacePermissions < Decidim::DepartmentAdmin::Permissions
      def initialize(*)
        self.class.delegate_chain= [Decidim::Assemblies::Permissions, Decidim::Admin::Permissions]
        super
      end
    end
  end
end
