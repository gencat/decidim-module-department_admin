# Decidim::DepartmentAdmin

This Dedicim's module produces a new \"department admin\" role which restricts the permissions of an Admin into participatory spaces of a given Area.

The module currently only affects the following participatory spaces and admin blocks:

- Participatory Processes: administer processes with the same area as the user's one.
- Assemblies: administer assemblies with the same area as the user's one.
- Newsletters: send newsletters to participants in the spaces with the same area as user's one.
- Conferences: administer conferences with the same area as the user's one.

## Usage

DepartmentAdmin will only affect users with the "department admin" role. The rest of the users should behave as usual.

To create a user with a department admin role, go to admin panel/PARTICIPANTS/Administrators/New Participant. There, select the "Administrador de departament" role, and then the area. Finally Invite the user.

## Installation

Add this line to your application's Gemfile if you would like to always have the latest (edge) version:

```ruby
gem "decidim-department_admin", git: "https://github.com/gencat/decidim-module-department-admin.git"
```

Or, add a line like the following to your application's Gemfile if you would like to have the latest stable from the version of your choice, in this case `0.4.x`:

```ruby
gem "decidim-department_admin", "~> 0.4.2", git: "https://github.com/gencat/decidim-module-department-admin.git"
```

Edit your app's `config/application.rb` file to enforce railties ordering:
```ruby
module YourDecidimApp
  class Application < Rails::Application

...
    config.railties_order = [:main_app, ::Decidim::DepartmentAdmin::Engine, :all]
...

  end
end
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

`Decidim::Assemblies::ParticipatorySpacePermissions`, `Decidim::ParticipatoryProcesses::ParticipatorySpacePermissions` and
`Decidim::Conferences::ParticipatorySpacePermissions` are subclassing `Decidim::DepartmentAdmin::Permissions` in order to force the permissions classes where they delegate.

### Decorators
Inside `app/decorators` there are all the tricks done in order for department_admin module to work.

All decorator artifacts are extensions or modifications to the standard Decidim behavior.

### Temporal fixes

#### Temporal fix: added & in case role_name check.

Currently, in the file:
- lib/decidim/participatory_space_resourceable.rb
we have overridden `user_role_config_for` method, in role_name case check.

The reason for this, is that this method is called from `user_role_config` in `Decidim::Admin::UserRolesHelper` file, with second param `role_name` that can be nil as it is called as `role&.role`.
This happens only when logged in user is Departmental Admin type and this can be possible because this module is only available in this repo.
So, to avoid error when role_name passed is nil, we override this param check with a simple `role_name&.to_sym`

In next versions, this issue will be patched in `decidim/decidim`, so this override could be removed:
- lib/decidim/participatory_space_resourceable.rb

### Run tests

Create a dummy app in your application (if not present):

```bash
bin/rails decidim:generate_external_test_app
cd spec/decidim_dummy_app/
bundle exec rails decidim_department_admin:install:migrations
RAILS_ENV=test bundle exec rails db:migrate
sed -ie '/^  class Application < Rails::Application/a config.railties_order = [:main_app, ::Decidim::DepartmentAdmin::Engine, :all]' config/application.rb
```

This last line modifies dummy_app's `config/application.rb` file to enforce railties ordering, adding:
```ruby
module DecidimDepartmentAdminTestApp
  class Application < Rails::Application
    config.railties_order = [:main_app, ::Decidim::DepartmentAdmin::Engine, :all]
...

  end
end
```

And run tests:

```bash
bundle exec rspec spec
```

## Contributing

See [Decidim](https://github.com/decidim/decidim).

## License

This engine is distributed under the GNU AFFERO GENERAL PUBLIC LICENSE.

Authored by [CodiTramuntana](http://coditramuntana.com).
