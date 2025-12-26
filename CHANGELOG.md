## [Unreleased]

## [0.1.0] - 2024-12-26

### Initial Release

A Rails generator gem that scaffolds Claude AI skills and agents for Rails projects, making AI-assisted development reusable and distributable.

### Generators
- **Install Generator** (`rails g claude:install`) - Initialize Claude skills with three presets (basic, fullstack, api)
- **Skill Generator** (`rails g claude:skill`) - Create custom skills with templates (generic, model, controller, frontend)
- **Agent Generator** (`rails g claude:agent`) - Create custom AI agents
- **Command Generator** (`rails g claude:command`) - Create custom slash commands
- **Rule Generator** (`rails g claude:rule`) - Create project-specific rules with templates (generic, testing, security, performance)
- **Context Generator** (`rails g claude:context`) - Scaffold complete domain setups
  - Pre-built contexts: ecommerce, saas (with full templates, agents, and example models)
- **Views Generator** (`rails g claude:views`) - Copy and customize gem resources

### Pre-built Skills (18 total)
**Core Rails:**
- rails-models (ActiveRecord, migrations, validations, associations)
- rails-controllers (routing, actions, REST conventions)
- rails-views (ERB templates, helpers, partials)

**Full-Stack Development:**
- rails-hotwire (Turbo Drive, Frames, Streams, Stimulus)
- tailwindcss (utility-first CSS)

**Background Processing & Communication:**
- rails-jobs (background jobs with Solid Queue)
- rails-mailers (ActionMailer patterns)

**Authentication & Authorization:**
- rails-auth-with-devise (authentication with Devise, OmniAuth, API auth)
- rails-authorization-cancancan (role-based access control)

**API Development:**
- rails-api-controllers (RESTful API patterns, versioning, authentication, rate limiting, CORS, pagination)

**Testing:**
- rspec-testing (RSpec patterns and best practices)
- minitest-testing (Minitest patterns)

**Utilities:**
- rails-debugging (debugging tools and systematic process)
- rails-pagination-kaminari (pagination patterns)
- rails-deployment (deployment best practices)

**Planning & Organization:**
- plan-feature (feature planning workflow)
- refine-requirements (requirements refinement)
- create-task-files (task file creation)

### Pre-built Commands (5 total)
- quality (run linters and formatters)
- turbo-feature (scaffold Hotwire Turbo features)
- stimulus (create Stimulus controllers)
- create-pr (create GitHub pull requests)
- dbchange (database migration workflow)

### Pre-built Rules (5 total)
- code-style (coding standards)
- testing (test requirements)
- security (security guidelines)
- database (database best practices)
- hotwire (Hotwire conventions)

### Pre-built Agents
- basic-dev (models, controllers, views)
- fullstack-dev (all skills including Hotwire and Tailwind)
- api-dev (API-focused development)

### Features
- Configuration system with settings.local.json
- Support for Ruby 3.0+ and Rails 7.0+
- Three installation presets (basic, fullstack, api)
- Comprehensive documentation and examples
- CI/CD with GitHub Actions
