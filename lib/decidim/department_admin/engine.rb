# frozen_string_literal: true

require "rails"
require "decidim/core"

module Decidim
  module DepartmentAdmin
    # This is the engine that runs on the public interface of department_admin.
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::DepartmentAdmin

      config.autoload_paths << (Decidim::DepartmentAdmin::Engine.root + "app/decorators")

      routes do
        # Add engine routes here
        # resources :department_admin
        # root to: "department_admin#index"
      end

      initializer "decidim_department_admin.assets" do |app|
        app.config.assets.precompile += %w[decidim_department_admin_manifest.js decidim_department_admin_manifest.css]
      end

      initializer "decidim_department_admin.autoload_paths" do |app|
        ActiveSupport::Dependencies.autoload_paths << (Decidim::DepartmentAdmin::Engine.root + "app/decorators")
      end

      config.to_prepare do
        Dir.glob(Decidim::DepartmentAdmin::Engine.root + "app/decorators/**/*_decorator*.rb").each do |c|
          require_dependency(c)
        end
      end

    end
  end
end
