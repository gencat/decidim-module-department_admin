# frozen_string_literal: true

# Intercepts the `call` method and forces the Area of the user if it is a
# department_admin user.
Decidim::ParticipatoryProcesses::Admin::UpdateParticipatoryProcess.class_eval do
  alias_method :original_call, :call

  def call
    author = form.current_user
    form.area_id = author.areas.first.id if author.department_admin?
    original_call
  end
end
