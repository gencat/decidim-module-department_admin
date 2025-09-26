# frozen_string_literal: true

Deface::Override.new(
  virtual_path: "decidim/participatory_processes/admin/participatory_processes/_form",
  name: "disable-area-id-select-in-participatory_processes-form",
  replace: "erb[loud]:contains('form.areas_select :area_id')",
  text: <<-ERB
    <%= form.areas_select :area_id,
          areas_for_select(current_organization),
          { include_blank: t(".select_an_area"), selected: current_user.areas.first&.id },
          { disabled: true } %>
  ERB
)

Deface::Override.new(
  virtual_path: "decidim/assemblies/admin/assemblies/_form",
  name: "disable-area-id-select-in-assemblies-form",
  replace: "erb[loud]:contains('form.areas_select :area_id')",
  text: <<-ERB
    <%= form.areas_select :area_id,
          areas_for_select(current_organization),
          { include_blank: t(".select_an_area"), selected: current_user.areas.first&.id },
          { disabled: true } %>
  ERB
)
