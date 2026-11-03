# frozen_string_literal: true

Deface::Override.new(
  virtual_path: "decidim/assemblies/admin/assemblies/_assembly_row",
  name: "add-department-columns-to-assembly-row",
  insert_after: "td:nth-child(2)",
  text: <<-ERB
    <td class="table-list__area" data-label="<%= t("models.assembly.fields.department", scope: "decidim.admin") %>">
      <%= translated_attribute(assembly.department.name) if assembly.department.present? %>
    </td>
    <td class="table-list__area-users" data-label="<%= t("models.assembly.fields.department_role", scope: "decidim.admin") %>">
      <%= assembly.department.users.map(&:name).join(", ") if assembly.department.present? %>
    </td>
    <td class="table-list__role" data-label="<%= t("models.assembly.fields.assembly_role", scope: "decidim.admin") %>">
      <%= assembly.users_with_any_role.map(&:name).join(", ") %>
    </td>
  ERB
)
