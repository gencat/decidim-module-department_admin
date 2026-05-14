# frozen_string_literal: true

# Radio buttons inside the search form so filter_search is submitted with the query
Deface::Override.new(virtual_path: "decidim/admin/shared/_filters",
                     name: "add_search_mode_radios_to_filters",
                     insert_after: "div.input-group",
                     partial: "decidim/admin/users/search_mode_filter")

# Role select outside the form, navigates via URL
Deface::Override.new(virtual_path: "decidim/admin/shared/_filters",
                     name: "add_role_filter_to_filters",
                     insert_after: "div.filters__section",
                     partial: "decidim/admin/users/role_filter")
