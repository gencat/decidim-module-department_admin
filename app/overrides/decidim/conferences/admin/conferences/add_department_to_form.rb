# frozen_string_literal: true

Deface::Override.new(
  virtual_path: "decidim/conferences/admin/conferences/_form",
  name: "add-department-select-to-conferences-form",
  insert_after: "#accordion-taxonomies",
  text: <<-ERB
    <div class="card" data-controller="accordion" id="accordion-department">
      <div class="card-divider">
        <button class="card-divider-button" data-open="true" data-controls="panel-department" type="button">
          <%= icon "arrow-right-s-line" %>
          <h2 class="card-title" id="department">
            <%= t("department", scope: "decidim.conferences.admin.conferences.form") %>
          </h2>
        </button>
      </div>
      <div id="panel-department" class="card-section">
        <div class="row column">
          <%= form.select :decidim_department_admin_department_id,
            departments_for_select(current_organization),
            { include_blank: t("decidim.department_admin.admin.forms.select_a_department"),
              selected: current_participatory_space.try(:decidim_department_admin_department_id) } %>
        </div>
      </div>
    </div>
  ERB
)
