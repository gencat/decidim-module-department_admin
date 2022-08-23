# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)

require "decidim/department_admin/version"

DECIDIM_VER = "~> 0.26.2"

Gem::Specification.new do |s|
  s.version = Decidim::DepartmentAdmin.version
  s.authors = ["Oliver Valls"]
  s.email = ["oliver.vh@coditramuntana.com"]
  s.license = "AGPL-3.0"
  s.homepage = "https://github.com/decidim/decidim-module-department_admin"
  s.required_ruby_version = ">= 2.7"

  s.name = "decidim-department_admin"
  s.summary = "A decidim department_admin module"
  s.description = "This Dedicim's module produces a new \"department admin\" role which restricts the permissions of an Admin into participatory spaces of a given Area."

  s.files = Dir["{app,db,config,lib}/**/*", "LICENSE-AGPLv3.txt", "Rakefile", "README.md"]
  s.test_files = Dir["spec/**/*"]

  s.add_dependency "decidim-admin", DECIDIM_VER
  s.add_dependency "decidim-core", DECIDIM_VER
  s.add_development_dependency "decidim", DECIDIM_VER
  s.add_development_dependency "decidim-conferences", DECIDIM_VER
  s.add_development_dependency "decidim-dev", DECIDIM_VER
end
