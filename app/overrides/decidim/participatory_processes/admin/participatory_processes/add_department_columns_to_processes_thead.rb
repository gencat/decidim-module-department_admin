# frozen_string_literal: true

Deface::Override.new(
  virtual_path: "decidim/participatory_processes/admin/participatory_processes/_processes_thead",
  name: "add-department-columns-to-processes-thead",
  insert_after: "th:first-child",
  text: <<-ERB
    <th>
      <%= sort_link(query, :department_name, t("models.participatory_process.fields.department", scope: "decidim.admin")) %>
    </th>
    <th>
      <%= t("models.participatory_process.fields.department_role", scope: "decidim.admin") %>
    </th>
    <th>
      <%= t("models.participatory_process.fields.process_role", scope: "decidim.admin") %>
    </th>
  ERB
)
