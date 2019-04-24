# frozen_string_literal: true

# Intercepts the `call` method and forces the Area of the user if it is a
# department_admin user.
Decidim::ParticipatoryProcesses::Admin::CreateParticipatoryProcess.class_eval do

  alias_method :original_call, :call

  def call
    author= form.current_user
    if author.role? 'department_admin'
      form.area_id= author.areas.first.id
    end
    original_call
  end
end
