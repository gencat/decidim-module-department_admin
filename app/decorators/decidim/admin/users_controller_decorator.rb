# frozen_string_literal: true

require_dependency 'decidim/admin/users_controller'

# Sort Admins by role and area
::Decidim::Admin::UsersController.class_eval do
  alias_method :original_collection, :collection
  helper_method :sort_order_spaces

  before_action :set_global_params

  def collection
    users= original_collection
    Decidim::Admin::UserAdminFilter.for(users,@query, @process_name,@role)
  end

  # It is necessary to overwrite this method to correctly locate the user.
  # because we overwrite the collection method
  def user
    @user ||= original_collection.find(params[:id])
  end

  def show
    locale = params[:locale] || "ca"
    @user ||= original_collection.find(params[:id])
    @spaces = []
    @user.participatory_processes.each do |process|
      if process.participatory_process_group then
        if process.participatory_process_group&.name[locale] != '' then
          type = process.participatory_process_group&.name[locale]
        else 
          type = process.participatory_process_group&.name["ca"]
        end
      else 
        type = t("models.user.fields.process_type", scope: "decidim.admin")
      end
      process_title = process.title[locale]
      if process_title == '' then
        process_title = process.title["ca"]
      end
      @spaces.push({"title" => process_title,
                    "type" => type,
                    "area" => process.area&.name[locale],
                    "created_at" => process.created_at,
                    "private" => process.private_space?,
                    "published" => process.published?})
    end

    @user.assemblies.each do |assembly|
      
      if assembly.area && assembly.area.name then
        area_name = assembly.area.name[locale]
      else
        area_name = ""
      end

      assembly_title = assembly.title[locale]
      if assembly_title == '' then
        assembly_title = assembly.title["ca"]
      end

      @spaces.push({"title" => assembly_title, 
                    "type" => t("models.user.fields.assembly_type", scope: "decidim.admin"),
                    "area" => area_name,
                    "created_at" => assembly.created_at,
                    "private" => assembly.private_space?,
                    "published" => assembly.published?})
    end

    if params[:sort_column] && (params[:sort_column] == 'published' || params[:sort_column] == 'private') && params[:sort_order] && params[:sort_order] == 'asc' then
      @spaces.sort! { |x, y| x[params[:sort_column]] ? 0 : 1 <=> y[params[:sort_column]] ? 0 : 1 }
    elsif params[:sort_column] && (params[:sort_column] == 'published' || params[:sort_column] == 'private') && params[:sort_order] && params[:sort_order] == 'desc' then
      @spaces.sort! { |x, y| y[params[:sort_column]] ? 0 : 1 <=> x[params[:sort_column]] ? 0 : 1 }
    elsif params[:sort_column] && params[:sort_order] && params[:sort_order] == 'asc' then
      @spaces.sort! { |x, y| x[params[:sort_column]] <=> y[params[:sort_column]]}
    elsif params[:sort_column] && params[:sort_order] && params[:sort_order] == 'desc' then
      @spaces.sort! { |x, y| y[params[:sort_column]] <=> x[params[:sort_column]]}
    else
      @spaces.sort! {|x, y| y["title"] <=> x["title"]}
    end
  end
  
  def sort_spaces(column, order)
    @spaces.sort! {|x, y| x[column] <=> y[column]}.reverse
  end

  def set_global_params
    @query = params[:q]
    @process_name = params[:process_name]
    @role = params[:role]
  end
end
