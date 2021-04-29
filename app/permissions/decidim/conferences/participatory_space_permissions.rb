# frozen_string_literal: true

if defined?(Decidim::Conferences)
  module Decidim
    module Conferences
      class ParticipatorySpacePermissions < Decidim::DepartmentAdmin::Permissions
        def initialize(*)
          # This are the same permissions as Decidim's conferences space.
          # Right now are the same for admin and public views
          self.class.delegate_chain = [Decidim::Conferences::Permissions]
          super
        end
      end
    end
  end
end
