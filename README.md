# Decidim::DepartmentAdmin

This Dedicim's module produces a new \"department admin\" role which restricts the permissions of an Admin into participatory spaces of a given Area.

The module currently only affects the following participatory spaces and admin blocks:

- Participatory Processes: administer processes with the same area as the user's one.
- Assemblies: administer assemblies with the same area as the user's one.
- Newsletters: send newsletters to participants in the spaces with the same area as user's one.

## Usage

DepartmentAdmin will only affect users with the "department admin" role. The rest of the users should behave as usual.

To create a user with a department admin role, go to admin panel/PARTICIPANTS/Administrators/New Participant. There, select the "Administrador de departament" role, and then the area. Finally Invite the user.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'decidim-department_admin
```

And then execute:

```bash
bundle
bundle exec rails decidim_department_admin:install:migrations
bundle exec rails db:migrate
```

## Overrides
Beware that this module overrides many core features of Decidim. Thus, modified features may have required to override, change or extend source code from Decidim.

Most of the times the overrides and modifications will be found in `app/decorators`.

## How it works
Although some other artifacts exist, the key places to search for in this module are 3:
- lib/decidim/department_admin/engine.rb
- app/permissions/decidim/department_admin/permissions.rb
- app/decorators

### Engine
The mission of the Engine in this module is to reconfigure the permissions_registry for some artifacts so that they depend upon `Decidim::DepartmentAdmin::Permissions` instead of their standard permissions chain.

The engine also configures de `app/decorators` directory to be loaded during rails initialization.

### Custom Permissions
The `Decidim::DepartmentAdmin::Permissions` class is the responsible to allow all permissions related with the "departmen admin" role.

`Decidim::Assemblies::ParticipatorySpacePermissions` and `Decidim::ParticipatoryProcesses::ParticipatorySpacePermissions` are subclassing `Decidim::DepartmentAdmin::Permissions` in order to force the permissions classes where they delegate.

### Decorators
Inside `app/decorators` there are all the tricks done in order for department_admin module to work.

All decorator artifacts are extensions or modifications to the standard Decidim behavior.

## Contributing

See [Decidim](https://github.com/decidim/decidim).

### Run tests

Create a dummy app in your application (if not present):

```bash
bin/rails decidim:generate_external_test_app
cd spec/decidim_dummy_app/
bundle exec rails decidim_department_admin:install:migrations
RAILS_ENV=test bundle exec rails db:migrate
```

Edit dummy_app's `config/application.rb` file to enforce railties ordering:
```ruby
module DecidimDepartmentAdminTestApp
  class Application < Rails::Application

...
    config.railties_order = [Decidim::Core::Engine, Decidim::DepartmentAdmin::Engine, :main_app, :all]
...

  end
end
```

And run tests:

```bash
bundle exec rspec spec
```

## License

This engine is distributed under the GNU AFFERO GENERAL PUBLIC LICENSE.

Authored by [CodiTramuntana](http://coditramuntana.com).

