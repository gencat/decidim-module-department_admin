# frozen_string_literal: true

require_dependency "decidim/admin/users_controller"

# This decorator adds the capability to the controller to query users
# filtering by User role `department_admin`.
module Decidim::Admin::UsersControllerDecorator
  # rubocop: disable Metrics/CyclomaticComplexity
  # rubocop: disable Metrics/PerceivedComplexity
  def self.decorate
    # Sort Admins by role and area
    ::Decidim::Admin::UsersController.class_eval do
      alias_method :original_collection, :collection

      include ::Decidim::DepartmentAdmin::ApplicationHelper
      helper_method :roles_with_title, :filtered_collection

      before_action :read_params, only: :index

      def read_params
        @role = params[:role]
        @by_process_name = params[:filter_search] == "by_process_name"
        term = params.dig(:q, :name_or_nickname_or_email_cont)
        @search_text = term
      end

      def collection
        @collection ||= begin
          filtered = if @by_process_name
                       ::Decidim::Admin::UserAdminBySpaceNameFilter.for(@search_text, current_organization, current_locale)
                     else
                       ::Decidim::Admin::UserAdminFilter.for(original_collection, @search_text, @role, current_organization)
                     end
          if current_user.department_admin?
            filtered.joins(:areas)
                    .where("'department_admin' = ANY(roles)")
                    .where("decidim_areas.id": current_user.areas.pluck(:id))
          else
            filtered
          end
        end
      end

      # override decidim-admin/app/controllers/concerns/decidim/admin/filterable.rb#filtered_collection default behavior.
      def filtered_collection
        @filtered_collection ||= begin
          users = @by_process_name ? collection : query.result
          sorted_users = users.uniq.sort { |u_1, u_2| "#{u_1.active_role}||#{u_1.areas.first&.name}" <=> "#{u_2.active_role}||#{u_2.areas.first&.name}" }
          paginate(Kaminari.paginate_array(sorted_users))
        end
      end

      def show
        locale = params[:locale] || "ca"
        @user ||= original_collection.find(params[:id])
        @spaces = []
        @user.participatory_processes.each do |process|
          type = if process.participatory_process_group
                   if process.participatory_process_group&.title&.[](locale) == ""
                     process.participatory_process_group&.title&.[]("ca")
                   else
                     process.participatory_process_group&.title&.[](locale)
                   end
                 else
                   t("models.user.fields.process_type", scope: "decidim.admin")
                 end
          process_title = process.title[locale]
          process_title = process.title["ca"] if process_title == ""

          @spaces.push("title" => process_title,
                       "type" => type,
                       "area" => process.area.nil? ? "" : process.area&.name&.[](locale),
                       "created_at" => process.created_at,
                       "private" => process.private_space?,
                       "published" => process.published?)
        end

        @user.assemblies.each do |assembly|
          area_name = if assembly.area && assembly.area.name
                        assembly.area.name[locale]
                      else
                        ""
                      end

          assembly_title = assembly.title[locale]
          assembly_title = assembly.title["ca"] if assembly_title == ""

          @spaces.push("title" => assembly_title,
                       "type" => t("models.user.fields.assembly_type", scope: "decidim.admin"),
                       "area" => area_name,
                       "created_at" => assembly.created_at,
                       "private" => assembly.private_space?,
                       "published" => assembly.published?)
        end

        if Decidim::DepartmentAdmin.conferences_defined?
          @user.conferences.each do |conference|
            area_name = conference.area&.name.try(:[], locale) || ""

            conference_title = conference.title[locale]
            conference_title = conference.title["ca"] if conference_title.blank?

            @spaces.push("title" => conference_title,
                         "type" => t("models.user.fields.conference_type", scope: "decidim.admin"),
                         "area" => area_name,
                         "created_at" => conference.created_at,
                         "private" => conference.private_space?,
                         "published" => conference.published?)
          end
        end

        # rubocop: disable Style/NestedTernaryOperator
        if (params[:sort_column] == "published" || params[:sort_column] == "private") && params[:sort_order] == "asc"
          @spaces.sort! { |x, y| x[params[:sort_column]] ? 0 : (1 <=> y[params[:sort_column]] ? 0 : 1) }
        elsif (params[:sort_column] == "published" || params[:sort_column] == "private") && params[:sort_order] == "desc"
          @spaces.sort! { |x, y| y[params[:sort_column]] ? 0 : 1 <=> x[params[:sort_column]] ? 0 : 1 }
        elsif params[:sort_column] && params[:sort_order] && params[:sort_order] == "asc"
          @spaces.sort! { |x, y| x[params[:sort_column]] <=> y[params[:sort_column]] }
        elsif params[:sort_column] && params[:sort_order] && params[:sort_order] == "desc"
          @spaces.sort! { |x, y| y[params[:sort_column]] <=> x[params[:sort_column]] }
        else
          @spaces.sort! { |x, y| y["title"] <=> x["title"] }
        end
        # rubocop: enable Style/NestedTernaryOperator
      end
    end
  end
  # rubocop: enable Metrics/CyclomaticComplexity
  # rubocop: enable Metrics/PerceivedComplexity
end

::Decidim::Admin::UsersControllerDecorator.decorate
