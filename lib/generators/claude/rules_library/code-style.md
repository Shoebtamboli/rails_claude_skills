# Code Style Rules

This project follows Rails conventions and Ruby best practices.

## Key Principles

- **Convention over Configuration**: Prefer Rails defaults and conventions
- **Readability**: Code should be clear and self-documenting
- **Consistency**: Follow established patterns in the codebase

## Ruby Style

- Use 2 spaces for indentation (not tabs)
- Prefer double quotes for strings
- Use modern Ruby syntax (Ruby 3.0+)
- Prefer `&.` safe navigation over conditional checks
- Use trailing commas in multi-line arrays and hashes

## Rails Conventions

- Follow RESTful routing patterns
- Keep controllers skinny, models organized
- Use `before_action` callbacks for common controller setup
- Prefer strong parameters for mass assignment protection
- Use ActiveRecord query methods over raw SQL

## Naming

- Use snake_case for variables, methods, and file names
- Use PascalCase for class and module names
- Be descriptive: `user_signed_in?` not `signed_in?`
- Prefix predicate methods with `?` (e.g., `published?`)
- Prefix dangerous methods with `!` (e.g., `publish!`)

## Auto-Fixing

Run `bundle exec rubocop -a` to automatically fix style violations before committing.
