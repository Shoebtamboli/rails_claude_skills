## [Unreleased]

### Added
- **Context Generator**: New `rails g claude:context` command for domain-specific scaffolding
  - 6 pre-built contexts: ecommerce, saas, blog, social, api, marketplace
  - Each context includes relevant skills, custom agent, and example models
  - Context-specific documentation and implementation guides
- New pre-built skills:
  - rails-auth-with-devise (complete authentication with Devise, OmniAuth, and API auth)
  - rails-debugging (Rails-specific debugging tools and systematic debugging process)
  - rails-jobs (background jobs with SolidQueue, SolidCache, SolidCable - enforces TEAM RULE #1: NEVER Sidekiq/Redis)
  - rails-mailers (ActionMailer for transactional and notification emails with async delivery)
  - rspec-testing (comprehensive RSpec testing patterns and best practices)
  - rails-api-controllers (RESTful API patterns, versioning, authentication, rate limiting, CORS, pagination, API testing, and documentation)

### Changed
- Updated README to organize skills by category (Core Rails, Full-Stack Development, Background Processing & Communication, Authentication & Debugging, API Development)
- Enhanced roadmap to reflect Phase 2 and Phase 3 progress
- Added comprehensive usage examples including context scaffolding

## [0.1.0] - 2025-12-16

- Initial release
- Install generator with three presets (basic, fullstack, api)
- Skill generator for creating custom skills
- Agent generator for creating custom agents
- Views generator for customizing existing skills
- Pre-built skills:
  - rails-models (ActiveRecord, migrations, validations, associations)
  - rails-controllers (routing, actions, REST conventions)
  - rails-views (ERB templates, helpers, partials)
  - rails-hotwire (Turbo Drive, Frames, Streams, Stimulus)
  - tailwindcss (utility-first CSS)
- Pre-built agents:
  - basic-dev (models, controllers, views)
  - fullstack-dev (all skills including Hotwire and Tailwind)
  - api-dev (API-focused development)
- Configuration system with settings.local.json
- Comprehensive documentation and examples
