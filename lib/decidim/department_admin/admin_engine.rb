# frozen_string_literal: true

module Decidim
  module DepartmentAdmin
    # This is the engine that runs on the public interface of `DepartmentAdmin`.
    class AdminEngine < ::Rails::Engine
      isolate_namespace Decidim::DepartmentAdmin::Admin

      paths['db/migrate'] = nil
      paths['lib/tasks'] = nil

      routes do
        # Add admin engine routes here
        # resources :department_admin do
        #   collection do
        #     resources :exports, only: [:create]
        #   end
        # end
        # root to: "department_admin#index"
      end

      def load_seed
        nil
      end
    end
  end
end
