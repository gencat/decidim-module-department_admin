# frozen_string_literal: true

require_dependency "decidim/admin/users_controller"

# This decorator adds the capability to the controller to query users
# filtering by User role `department_admin`.

# Sort Admins by role and area
::Decidim::Admin::UsersController.class_eval do
  alias_method :original_collection, :collection

  helper_method :sort_order_spaces
  include ::Decidim::DepartmentAdmin::ApplicationHelper
  helper_method :roles_with_title

  before_action :set_global_params

  def collection
    if current_user.department_admin?
      @collection ||= current_organization.users_with_any_role
                                          .joins(:areas)
                                          .where("'department_admin' = ANY(roles)")
                                          .where('decidim_areas.id': current_user.areas.pluck(:id))
    else
      original_collection
    end
  end

  # override decidim-admin/app/controllers/concerns/decidim/admin/filterable.rb#filtered_collection default behavior.
  def filtered_collection
    users = query.result
    sorted_users = users.sort { |u_1, u_2| "#{u_1.active_role}||#{u_1.areas.first&.name}" <=> "#{u_2.active_role}||#{u_2.areas.first&.name}" }
    paginate(Kaminari.paginate_array(sorted_users))
  end

  # It is necessary to overwrite this method to correctly locate the user.
  # because we overwrite the collection method
  def user
    @user ||= original_collection.find(params[:id])
  end

  # rubocop: disable Metrics/CyclomaticComplexity
  # rubocop: disable Metrics/PerceivedComplexity
  def show
    locale = params[:locale] || "ca"
    @user ||= original_collection.find(params[:id])
    @spaces = []
    @user.participatory_processes.each do |process|
      type = if process.participatory_process_group
               if process.participatory_process_group&.name&.[](locale) != ""
                 process.participatory_process_group&.name&.[](locale)
               else
                 process.participatory_process_group&.name&.[]("ca")
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
  # rubocop: enable Metrics/CyclomaticComplexity
  # rubocop: enable Metrics/PerceivedComplexity

  def sort_spaces(column, _order)
    @spaces.sort! { |x, y| x[column] <=> y[column] }.reverse
  end

  def set_global_params
    @query = params[:q]
    @search_text = params[:search_text]
    @role = params[:role]
  end
end
