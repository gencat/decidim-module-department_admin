# frozen_string_literal: true

module Decidim
  module DepartmentAdmin
    module Admin
      class UpdateDepartment < Decidim::Commands::UpdateResource
        fetch_form_attributes :name
      end
    end
  end
end
