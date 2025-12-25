---
paths: spec/**/*,test/**/*
---

# Testing Rules

This project values comprehensive test coverage.

## Test Structure

- One test file per model/controller/component
- Use descriptive test names
- Group related tests with clear organization
- Keep tests focused and independent

## Test Types

### Model Tests
- Test validations
- Test associations
- Test custom methods
- Test scopes and queries

### Controller Tests
- Test HTTP responses (200, 302, 404, etc.)
- Test authentication/authorization
- Test parameter handling
- Avoid testing view rendering details

### System/Integration Tests
- Test critical user workflows end-to-end
- Test JavaScript/Hotwire behavior
- Keep tests for happy paths and critical features

## Best Practices

- Write tests before or alongside code (TDD/BDD)
- Use factories or fixtures for test data
- Mock external services
- Keep tests fast and isolated
- Test edge cases and error conditions

## Running Tests

- Run full suite regularly
- Run specific tests during development
- Ensure tests pass before committing
