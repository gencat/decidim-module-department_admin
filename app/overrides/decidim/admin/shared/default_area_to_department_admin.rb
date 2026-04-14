# frozen_string_literal: true

Deface::Override.new(
  virtual_path: "decidim/participatory_processes/admin/participatory_processes/_form",
  name: "disable-area-id-select-in-participatory_processes-form",
  replace: "erb[loud]:contains('form.areas_select :area_id')",
  original: "a289e81f184835641bff316c64e025548d9cf8df",
  text: <<-ERB
    <%= form.areas_select :area_id,
          areas_for_select(current_organization),
          { include_blank: t(".select_an_area"), selected: current_user.department_admin? ? current_user.areas.first&.id : current_participatory_process.try(:decidim_area_id) },
          { disabled: current_user.department_admin? } %>
  ERB
)

Deface::Override.new(
  virtual_path: "decidim/assemblies/admin/assemblies/_form",
  name: "disable-area-id-select-in-assemblies-form",
  replace: "erb[loud]:contains('form.areas_select :area_id')",
  original: "ff3cffc75819bdc1154883fb28d811e51e923e40",
  text: <<-ERB
    <%= form.areas_select :area_id,
          areas_for_select(current_organization),
          { include_blank: t(".select_an_area"), selected: current_user.department_admin? ? current_user.areas.first&.id : current_assembly.try(:decidim_area_id) },
          { disabled: current_user.department_admin? } %>
  ERB
)
