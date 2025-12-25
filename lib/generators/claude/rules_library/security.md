# Security Rules

Security is a top priority in this Rails application.

## Input Validation

- Always use strong parameters in controllers
- Validate and sanitize user input
- Use ActiveRecord validations
- Never trust user input

## Authentication & Authorization

- Implement proper authentication (Devise, has_secure_password, etc.)
- Use authorization gems (Pundit, CanCanCan) for complex permissions
- Protect sensitive actions with before_action filters
- Use secure session configuration

## Database Security

- Never commit database credentials
- Use environment variables for sensitive configuration
- Prevent SQL injection by using ActiveRecord query methods
- Add database-level constraints when appropriate

## CSRF Protection

- Keep CSRF protection enabled (default in Rails)
- Use `protect_from_forgery` in ApplicationController
- Include authenticity tokens in forms

## Common Vulnerabilities

Protect against:
- SQL Injection: Use parameterized queries
- XSS: Sanitize output, use content_tag helpers
- Mass Assignment: Use strong parameters
- CSRF: Use Rails default protections
- Insecure Direct Object References: Authorize resource access

## Dependency Management

- Keep gems up to date
- Run `bundle audit` regularly
- Use Dependabot or similar tools
- Review security advisories

## Best Practices

- Follow OWASP Top 10 guidelines
- Use HTTPS in production
- Implement rate limiting for APIs
- Log security events
- Regular security audits with Brakeman
