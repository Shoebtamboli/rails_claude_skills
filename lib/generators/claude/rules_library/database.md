---
paths: db/**/*,app/models/**/*
---

# Database Rules

Guidelines for working with the database and ActiveRecord models.

## Migration Best Practices

- Always make migrations reversible
- Add indexes for foreign keys
- Use `change` method instead of up/down when possible
- Add null/default constraints at database level
- Include comments for complex migrations

## Migration Safety

- Never modify migrations that have been deployed to production
- Use background migrations for large data changes
- Consider downtime for destructive changes
- Test migrations in development first
- Keep migrations focused on one change

## Model Design

- Keep business logic in models
- Use concerns for shared behavior
- Implement proper associations
- Add database-level validations
- Use scopes for common queries

## Query Optimization

- Use `includes` to avoid N+1 queries
- Add appropriate indexes
- Use `select` to limit columns when needed
- Leverage database-specific features when appropriate
- Monitor query performance

## Schema Integrity

- Use foreign key constraints
- Add appropriate indexes
- Set null constraints appropriately
- Use enums for fixed sets of values
- Maintain referential integrity
