# frozen_string_literal: true

module Decidim
  module Conferences
    if Decidim::DepartmentAdmin.conferences_defined?
      class ParticipatorySpacePermissions < Decidim::DepartmentAdmin::Permissions
        def initialize(*)
          # This are the same permissions as Decidim's conferences space.
          # Right now are the same for admin and public views
          self.class.delegate_chain = [Decidim::Conferences::Permissions]
          super
        end
      end
    else
      class ParticipatorySpacePermissions
      end
    end
  end
end
