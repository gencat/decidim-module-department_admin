# frozen_string_literal: true

Deface::Override.new(
  virtual_path: "decidim/conferences/admin/conferences/_conference_row",
  name: "add-department-columns-to-conference-row",
  insert_after: "td:first-child",
  text: <<-ERB
    <td data-label="<%= t("models.conference.fields.department", scope: "decidim.admin") %>">
      <%= translated_attribute(conference.department.name) if conference.department.present? %>
    </td>
    <td data-label="<%= t("models.conference.fields.department_role", scope: "decidim.admin") %>">
      <%= conference.department.users.map(&:name).join(", ") if conference.department.present? %>
    </td>
    <td data-label="<%= t("models.conference.fields.conference_role", scope: "decidim.admin") %>">
      <%= conference.users_with_any_role.map(&:name).join(", ") %>
    </td>
  ERB
)
