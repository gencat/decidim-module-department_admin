# Changelog
Following Semantic Versioning 2.
This project is in BETA, but going to be tested in production.

## next version:

## Version 0.0.3 (MINOR)
- REFACTOR: Hack Decidim::User::ROLES.freeze to be able to not overwrite Decidim::User::ROLES, which causes many dependency loading order problems, instead it adds department_admin role to the list.

## Version 0.0.2 (MINOR)
- Remove component declaration for department_admin. (#10)

## Version 0.0.1 (MAJOR)
- Initial version.
