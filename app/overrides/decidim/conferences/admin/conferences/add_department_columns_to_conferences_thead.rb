# frozen_string_literal: true

Deface::Override.new(
  virtual_path: "decidim/conferences/admin/conferences/_conferences_thead",
  name: "add-department-columns-to-conferences-thead",
  insert_after: "th:first-child",
  text: <<-ERB
    <th><%= sort_link(query, :department_name, t("models.conference.fields.department", scope: "decidim.admin")) %></th>
    <th><%= t("models.conference.fields.department_role", scope: "decidim.admin") %></th>
    <th><%= t("models.conference.fields.conference_role", scope: "decidim.admin") %></th>
  ERB
)
