# frozen_string_literal: true

module Decidim
  module DepartmentAdmin
    module Admin
      class DepartmentsController < Decidim::Admin::ApplicationController
        layout "decidim/admin/settings"
        
        add_breadcrumb_item_from_menu :admin_settings_menu

        helper_method :department, :organization_departments

        def index
          enforce_permission_to :read, :department
          @departments = organization_departments
        end

        def new
          enforce_permission_to :create, :department
          @form = form(DepartmentForm).instance
        end

        def create
          enforce_permission_to :create, :department
          @form = form(DepartmentForm).from_params(params)

          CreateDepartment.call(@form) do
            on(:ok) do
              flash[:notice] = I18n.t("departments.create.success", scope: "decidim.department_admin.admin")
              redirect_to decidim_admin_department_admin.departments_path
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("departments.create.error", scope: "decidim.department_admin.admin")
              render :new
            end
          end
        end

        def edit
          enforce_permission_to :update, :department, department: department
          @form = form(DepartmentForm).from_model(department)
        end

        def update
          enforce_permission_to :update, :department, department: department
          @form = form(DepartmentForm).from_params(params)

          UpdateDepartment.call(@form, department) do
            on(:ok) do
              flash[:notice] = I18n.t("departments.update.success", scope: "decidim.department_admin.admin")
              redirect_to decidim_admin_department_admin.departments_path
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("departments.update.error", scope: "decidim.department_admin.admin")
              render :edit
            end
          end
        end

        def destroy
          enforce_permission_to :destroy, :department, department: department

          DestroyDepartment.call(department, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("departments.destroy.success", scope: "decidim.department_admin.admin")
              redirect_to decidim_admin_department_admin.departments_path
            end

            on(:has_department_admins) do
              flash[:alert] = I18n.t("departments.destroy.has_department_admins", scope: "decidim.department_admin.admin")
              redirect_to decidim_admin_department_admin.departments_path
            end
          end
        end

        private

        def organization_departments
          Decidim::DepartmentAdmin::Department.where(organization: current_organization)
        end

        def department
          return @department if defined?(@department)

          @department = organization_departments.find_by(id: params[:id])
        end
      end
    end
  end
end
