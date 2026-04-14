# frozen_string_literal: true

Deface::Override.new(virtual_path: "decidim/admin/shared/_filters",
                     name: "add_radio_buttons_to_filters",
                     insert_after: "div.input-group",
                     original: "e9f70bc093d7a62a5ca1600230d01d4516adae8e",
                     partial: "decidim/admin/users/filters")
