# frozen_string_literal: true

Deface::Override.new(
  virtual_path: "decidim/participatory_processes/admin/participatory_processes/_process_row",
  name: "add-department-columns-to-process-row",
  insert_after: "td:first-child",
  text: <<-ERB
    <td data-label="<%= t("models.participatory_process.fields.department", scope: "decidim.admin") %>">
      <%= translated_attribute(process.department.name) if process.department.present? %>
    </td>
    <td data-label="<%= t("models.participatory_process.fields.department_role", scope: "decidim.admin") %>">
      <%= process.department.users.map(&:name).join(", ") if process.department.present? %>
    </td>
    <td data-label="<%= t("models.participatory_process.fields.process_role", scope: "decidim.admin") %>">
      <%= process.users_with_any_role.map(&:name).join(", ") %>
    </td>
  ERB
)
