# frozen_string_literal: true

module Decidim
  module DepartmentAdmin
    module Admin
      class CreateDepartment < Decidim::Commands::CreateResource
        fetch_form_attributes :name, :organization

        protected

        def resource_class = Decidim::DepartmentAdmin::Department
      end
    end
  end
end
