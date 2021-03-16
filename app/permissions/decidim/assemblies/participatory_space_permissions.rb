# frozen_string_literal: true

module Decidim
  module Assemblies
    class ParticipatorySpacePermissions < Decidim::DepartmentAdmin::Permissions
      def initialize(*)
        # This are the same permissions as Decidim's assemblies space.
        # Right now are the same for admin and public views
        self.class.delegate_chain = [Decidim::Assemblies::Permissions]
        super
      end
    end
  end
end
