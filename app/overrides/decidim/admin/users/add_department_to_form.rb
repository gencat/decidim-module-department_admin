# frozen_string_literal: true

Deface::Override.new(
  virtual_path: "decidim/admin/users/_form",
  name: "add-department-select-to-users-form",
  insert_bottom: "div.card-section",
  text: <<-ERB
    <div id="department-block" class="row column" style="<%= "display:none;" unless @form.role == "department_admin" %>">
      <%= form.select :decidim_department_admin_department_id,
                      @form.available_departments_for_select,
                      { label: t("decidim.admin.users.form.department") },
                      { id: "user_department_id", disabled: current_user.roles.include?("department_admin") } %>
    </div>

    <%= javascript_tag do %>
      $('#user_role').on('change', function(ev) {
        if (ev.target.value == 'department_admin') {
          $('#department-block').show()
        } else {
          $('#department-block').hide()
        }
      })
    <% end %>
  ERB
)
