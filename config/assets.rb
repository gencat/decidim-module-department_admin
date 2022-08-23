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
