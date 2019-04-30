# frozen_string_literal: true

Decidim::Admin::NewslettersHelper.class_eval do
  alias_method :original_spaces_user_can_admin, :spaces_user_can_admin

  def spaces_user_can_admin
    author= current_user

    if author&.department_admin?
      return spaces_department_admin_can_admin
    end

    original_spaces_user_can_admin
  end

  def spaces_department_admin_can_admin
    @spaces_user_can_admin ||= {}
    Decidim.participatory_space_manifests.each do |manifest|
      organization_participatory_space(manifest.name)&.each do |space|
        next unless space.decidim_area_id.present?
        next unless current_user.areas.any?
        next unless space.decidim_area_id == current_user.areas.first.id
        @spaces_user_can_admin[manifest.name] ||= []
        space_as_option_for_select_data = space_as_option_for_select(space)
        @spaces_user_can_admin[manifest.name] << space_as_option_for_select_data unless @spaces_user_can_admin[manifest.name].detect do |x|
          x == space_as_option_for_select_data
        end
      end
    end
    @spaces_user_can_admin
  end
end
