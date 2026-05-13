# frozen_string_literal: true

module Decidim
  module DepartmentAdmin
    module Admin
      class DestroyDepartment < Decidim::Commands::DestroyResource
        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the form was not valid and we could not proceed.
        #
        # Returns nothing.
        def call
          destroy_resource
          broadcast(:ok)
        rescue ActiveRecord::RecordNotDestroyed
          broadcast(:has_spaces)
        end
      end
    end
  end
end
