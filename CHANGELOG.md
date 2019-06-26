# Changelog
Following Semantic Versioning 2.
This project is in BETA, but going to be tested in production.

## next version:

## Version 0.0.7 (MINOR)
- Fix Newsletters query. In admin newsletter list, filter newsletters only with same area/department than current user. 

## Version 0.0.6 (MINOR)
- Add a search field in admins index.

## Version 0.0.5 (PATCH)
- [REFACTOR] Use new `Decidim.user_roles` config_accessor for `Decidim::User` roles.

## Version 0.0.4 (MINOR)
- Add an area/department column in admins index.

## Version 0.0.3 (MINOR)
- REFACTOR: Hack Decidim::User::ROLES.freeze to be able to not overwrite Decidim::User::ROLES, which causes many dependency loading order problems, instead it adds department_admin role to the list.
- FIX: Add pending permissions so that department_admin can invite process admins.
- FIX: Add pending permissions so that department_admin can manage assembly members.

## Version 0.0.2 (MINOR)
- Remove component declaration for department_admin. (#10)

## Version 0.0.1 (MAJOR)
- Initial version.
