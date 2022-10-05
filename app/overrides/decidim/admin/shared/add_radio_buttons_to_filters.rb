# frozen_string_literal: true

Deface::Override.new(virtual_path: "decidim/admin/shared/_filters",
                     name: "add_radio_buttons_to_filters",
                     insert_after: "div.input-group",
                     partial: "decidim/admin/users/filters")
