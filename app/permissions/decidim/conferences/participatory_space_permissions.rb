# frozen_string_literal: true

module Decidim
  module Conferences
    parent_class = Decidim::DepartmentAdmin.conferences_defined? ? Decidim::DepartmentAdmin::Permissions : Object
    class ParticipatorySpacePermissions < parent_class
      def initialize(*)
        if Decidim::DepartmentAdmin.conferences_defined?
          # This are the same permissions as Decidim's conferences space.
          # Right now are the same for admin and public views
          self.class.delegate_chain = [Decidim::Conferences::Permissions]
        end
        super
      end
    end
  end
end
