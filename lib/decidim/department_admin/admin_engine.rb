# frozen_string_literal: true

module Decidim
  module DepartmentAdmin
    # This is the engine that runs on the public interface of `DepartmentAdmin`.
    class AdminEngine < ::Rails::Engine
      isolate_namespace Decidim::DepartmentAdmin::Admin

      paths["db/migrate"] = nil
      paths["lib/tasks"] = nil

      routes do
        resources :departments, except: [:show]
      end

      initializer "department_admin_admin.mount_routes" do
        Decidim::Core::Engine.routes do
          mount Decidim::DepartmentAdmin::AdminEngine,
                at: "/admin/department_admin",
                as: "decidim_admin_department_admin"
        end
      end

      initializer "department_admin.admin_settings_menu" do
        Decidim.menu :admin_settings_menu do |menu|
          menu.add_item :departments,
                        I18n.t("decidim.department_admin.admin.menu.departments"),
                        decidim_admin_department_admin.departments_path,
                        position: 1.55,
                        icon_name: "layout-masonry-line",
                        if: allowed_to?(:update, :organization, organization: current_organization),
                        active: is_active_link?(decidim_admin_department_admin.departments_path)
        end
      end

      def load_seed
        nil
      end
    end
  end
end
