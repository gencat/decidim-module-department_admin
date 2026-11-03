# frozen_string_literal: true

Deface::Override.new(
  virtual_path: "decidim/assemblies/admin/assemblies/_assemblies_thead",
  name: "add-department-columns-to-assemblies-thead",
  insert_after: "th:nth-child(2)",
  text: <<-ERB
    <th>
      <%= sort_link(query, :department_name, t("models.assembly.fields.department", scope: "decidim.admin")) %>
    </th>
    <th>
      <%= t("models.assembly.fields.department_role", scope: "decidim.admin") %>
    </th>
    <th>
      <%= t("models.assembly.fields.assembly_role", scope: "decidim.admin") %>
    </th>
  ERB
)
