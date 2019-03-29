# Decidim::DepartmentAdmin

This Dedicim's module produces a new \"department admin\" role which restricts the permissions of an Admin into participatory spaces of a given Area.

## Usage

DepartmentAdmin will be available as a Component for a Participatory
Space.

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

## Contributing

See [Decidim](https://github.com/decidim/decidim).

### Run tests

Create a dummy app in your application (if not present):

```bash
bin/rails decidim:generate_external_test_app
```

And run tests:

```bash
rspec spec
```

## License

This engine is distributed under the GNU AFFERO GENERAL PUBLIC LICENSE.
