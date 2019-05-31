# frozen_string_literal: true

require_dependency 'decidim/admin/users_controller'

# Sort Admins by role and area
::Decidim::Admin::UsersController.class_eval do
  alias_method :original_collection, :collection

  def index
    enforce_permission_to :read, :admin_user
    @query = params[:q]
    @role = params[:role]

    @users = Decidim::Admin::UserAdminFilter.for(
              current_organization.admins.or(current_organization.users_with_any_role),
              @query,
              @role
            ).page(params[:page]).per(15)
  end

  private

  def user
    @user ||= Decidim::User.find_by(
      id: params[:user_id],
      organization: current_organization
    )
  end
end
