# frozen_string_literal: true

# This file is located at `config/assets.rb` of your module.

base_path = File.expand_path("..", __dir__)

# Register the additonal path for Webpacker in order to make the module's
# stylesheets available for inclusion.
Decidim::Webpacker.register_path("#{base_path}/app/packs")

# Register the main application's stylesheet include statement:
# Decidim::Webpacker.register_stylesheet_import("stylesheets/decidim/your_component/your_component")

# Register the admin panel's stylesheet include statement:
# Decidim::Webpacker.register_stylesheet_import("stylesheets/decidim/your_component/your_component_admin", group: :admin)

# Register the entrypoints for your module. These entrypoints can be included
# within your application using `javascript_pack_tag` and if you include any
# SCSS files within the entrypoints, they become available for inclusion using
# `stylesheet_pack_tag`.
Decidim::Webpacker.register_entrypoints(
  decidim_department_admin: "#{base_path}/app/packs/entrypoints/decidim_department_admin.js"
)

# If you want to do the same but include the SCSS file for the admin panel's
# main SCSS file, you can use the following method.
Decidim::Webpacker.register_stylesheet_import("stylesheets/decidim/admin/department_admin", group: :admin)
