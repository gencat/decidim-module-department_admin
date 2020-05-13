# frozen_string_literal: true

require_dependency 'decidim/admin/users_controller'

# Sort Admins by role and area
::Decidim::Admin::UsersController.class_eval do
  alias_method :original_collection, :collection

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

  def set_global_params
    @query = params[:q]
    @process_name = params[:process_name]
    @role = params[:role]
  end
end
