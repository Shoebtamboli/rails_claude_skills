# Rails Claude Skills

[![Gem Version](https://badge.fury.io/rb/rails_claude_skills.svg)](https://badge.fury.io/rb/rails_claude_skills)
[![CI](https://github.com/shoebtamboli/rails_claude_skills/actions/workflows/ci.yml/badge.svg)](https://github.com/shoebtamboli/rails_claude_skills/actions/workflows/ci.yml)

A Rails generator gem that scaffolds Claude AI skills and agents for any Rails project, making AI-assisted development reusable and distributable.

## What is This?

`rails_claude_skills` brings Rails generator conventions to Claude AI skills. This gem provides generators to scaffold AI context and knowledge for your Rails projects.

### Why Use This Gem?

- **🔄 Reusability**: Share Claude skills across multiple Rails projects
- **👥 Team Collaboration**: Entire team gets consistent AI context
- **🔧 Maintainability**: Update skills in one place, distribute via gem updates
- **📝 Convention**: Follows Rails patterns developers already know
- **🔍 Discoverability**: Makes best practices easily accessible to AI assistants

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rails_claude_skills', group: :development
```

Then execute:

```bash
bundle install
```

## Quick Start

### 1. Initialize Claude Skills in Your Project

```bash
# Basic preset (models, controllers, views)
rails g claude:install

# Full-stack preset (includes Hotwire, TailwindCSS, RSpec)
rails g claude:install --preset=fullstack

# API preset (models, API controllers, serializers, authentication)
rails g claude:install --preset=api
```

This creates a `.claude/` directory in your Rails project:

```
your-rails-app/
├── .claude/
│   ├── settings.local.json
│   ├── README.md
│   ├── skills/           # Reusable AI knowledge modules
│   │   ├── rails-models/
│   │   ├── rails-controllers/
│   │   └── rails-views/
│   ├── commands/         # Custom slash commands
│   │   └── dbchange.md
│   ├── rules/            # Project-specific guidelines
│   │   ├── code-style.md
│   │   ├── testing.md
│   │   └── database.md
│   └── agents/           # AI agent definitions
│       └── rails-developer.md
```

### 2. Use with Claude Code

When you use Claude Code in your project, it automatically loads:
- **Skills** - Reusable knowledge modules for Rails patterns and conventions
- **Commands** - Custom slash commands for common workflows (e.g., `/dbchange`, `/quality`)
- **Rules** - Project-specific guidelines Claude follows when writing code
- **Agents** - Pre-configured AI assistants for different tasks

Claude will have deep knowledge of your tech stack and follow your team's conventions!

## Available Generators

### Install Generator

Initialize Claude skills in your project:

```bash
rails g claude:install [options]
```

**Options:**
- `--preset=basic` - Basic Rails skills (default)
- `--preset=fullstack` - Full-stack with Hotwire and TailwindCSS
- `--preset=api` - API-only configuration
- `--skip-agents` - Don't create default agents
- `--skip-readme` - Don't create README

**Presets Include:**

| Preset | Skills | Commands | Rules | Agent |
|--------|--------|----------|-------|-------|
| **basic** | rails-models, rails-controllers, rails-views | dbchange | code-style, testing, database | rails-developer |
| **fullstack** | basic + rails-hotwire, tailwindcss, rspec-testing | basic + quality, turbo-feature, stimulus, create-pr | basic + hotwire, security | fullstack-dev |
| **api** | rails-models, rails-api-controllers, rails-serializers | dbchange, quality | code-style, testing, security, database | api-dev |

Each preset includes:
- ✅ **Skills** for Rails patterns and best practices
- ✅ **Commands** for common development workflows
- ✅ **Rules** for code quality and conventions
- ✅ **Agent** pre-configured for the stack

### Skill Generator

Create a custom skill for your specific domain or patterns:

```bash
rails g claude:skill NAME [options]
```

**Options:**
- `--description=TEXT` - Skill description
- `--with-references` - Create references directory
- `--template=TYPE` - Use specific template (generic, model, controller, frontend)

**Examples:**

```bash
# Create a custom blog publishing skill
rails g claude:skill blog-publishing \
  --description="Blog-specific publishing patterns" \
  --with-references

# Create a payment processing skill
rails g claude:skill payment-processing \
  --template=model \
  --description="Stripe payment integration patterns"
```

### Agent Generator

Create a custom agent that combines multiple skills:

```bash
rails g claude:agent NAME [options]
```

**Options:**
- `--skills=skill1,skill2` - Skills to auto-load
- `--model=MODEL` - Default model (sonnet, opus, haiku)
- `--description=TEXT` - Agent description
- `--color=COLOR` - Agent color for UI

**Examples:**

```bash
# Create a backend development specialist
rails g claude:agent backend-dev \
  --skills=rails-models,rails-jobs,rspec-testing \
  --model=sonnet \
  --description="Backend development specialist"

# Create a frontend specialist
rails g claude:agent frontend-dev \
  --skills=rails-views,rails-hotwire,tailwindcss \
  --model=sonnet \
  --color=purple
```

### Command Generator

Create custom slash commands for common workflows:

```bash
rails g claude:command NAME [options]
```

**Options:**
- `--description=TEXT` - Command description
- `--argument-hint=HINT` - Argument usage hint
- `--allowed-tools=TOOLS` - Comma-separated list of allowed tools

**Examples:**

```bash
# Create a deploy command
rails g claude:command deploy \
  --description="Deploy to production" \
  --argument-hint="[environment]" \
  --allowed-tools="Bash, Read"

# Usage: /deploy staging
```

### Rule Generator

Create project-specific rules and guidelines:

```bash
rails g claude:rule NAME [options]
```

**Options:**
- `--paths=PATHS` - File paths where rule applies (comma-separated glob patterns)
- `--template=TYPE` - Template type (generic, testing, security, performance)

**Examples:**

```bash
# Create API design rules
rails g claude:rule api-design \
  --paths="app/controllers/api/**/*" \
  --template=security

# Create performance rules
rails g claude:rule performance \
  --template=performance
```

### Views Generator

Customize pre-built skills, commands, or rules by copying them to your project:

```bash
rails g claude:views NAME [options]
```

**Options:**
- `--type=TYPE` - Resource type: skill (default), command, rule

**Examples:**

```bash
# Customize a skill
rails g claude:views rails-models

# Customize a command
rails g claude:views quality --type=command

# Customize a rule
rails g claude:views security --type=rule

# Your changes will override the gem's default version
```

## Pre-Built Resources

### Skills

The gem includes 20+ pre-built skills organized by category:

**Rails Core**
- **rails-models** - ActiveRecord patterns, migrations, validations, callbacks, associations
- **rails-controllers** - Controller actions, routing, REST conventions, filters
- **rails-views** - ERB templates, helpers, layouts, partials
- **rails-hotwire** - Turbo Drive, Turbo Frames, Turbo Streams, Stimulus
- **rails-api-controllers** - RESTful API controllers, versioning, authentication, rate limiting

**Authentication & Authorization**
- **rails-auth-with-devise** - Complete authentication setup with Devise, including OmniAuth
- **rails-authorization-cancancan** - Authorization and permissions with CanCanCan

**Frontend**
- **tailwindcss** - TailwindCSS utility-first styling
- **rails-pagination-kaminari** - Pagination with Kaminari

**Background Jobs & Communication**
- **rails-jobs** - Background jobs with SolidQueue, SolidCache, SolidCable
- **rails-mailers** - ActionMailer for transactional and notification emails

**Testing**
- **rspec-testing** - RSpec testing patterns and best practices
- **minitest-testing** - Minitest tests for models, controllers, and system tests

**Utilities**
- **rails-debugging** - Rails-specific debugging tools
- **rails-deployment** - Deploy Rails apps (Kamal, Heroku, custom servers)

**Planning & Organization**
- **plan-feature** - Systematically gather requirements and create implementation plans
- **refine-requirements** - Clarify and improve feature requirements
- **create-task-files** - Export tasks to structured markdown files

### Commands

Pre-built slash commands for common workflows:

- **/quality** - Run RuboCop, Brakeman, and security audits
- **/turbo-feature** - Build Hotwire-powered features following best practices
- **/dbchange** - Generate database migrations with safety checks
- **/stimulus** - Generate Stimulus controllers with proper setup
- **/create-pr** - Create branch, commit, and open pull request

### Rules

Pre-built project guidelines:

- **code-style** - Ruby and Rails style conventions
- **testing** - Test structure and best practices
- **security** - Security guidelines and vulnerability prevention
- **database** - Database and ActiveRecord patterns
- **hotwire** - Turbo and Stimulus guidelines

## Usage Examples

### Example 1: New Rails Project Setup

```bash
# Create new Rails app
rails new blog_app
cd blog_app

# Add Claude skills
echo "gem 'rails_claude_skills', group: :development" >> Gemfile
bundle install

# Initialize with fullstack preset
rails g claude:install --preset=fullstack

# Start coding with AI assistance!
# .claude/ now contains all Rails + Hotwire + Tailwind expertise
```

### Example 2: Team Customization

```bash
# Lead developer sets up and customizes
rails g claude:install --preset=fullstack
rails g claude:views rails-models  # Customize for team conventions

# Edit .claude/skills/rails-models/SKILL.md with team-specific patterns

# Commit .claude/ to git
git add .claude/
git commit -m "Add Claude skills with team conventions"

# Other team members pull
git pull

# Everyone now has consistent AI context!
```

### Example 3: Adding Additional Pre-Built Skills

```bash
# After installing with a preset, add more skills as needed
rails g claude:install --preset=fullstack

# Add authentication with Devise
rails g claude:views rails-auth-with-devise

# Add authorization with CanCanCan
rails g claude:views rails-authorization-cancancan

# Add background job processing
rails g claude:views rails-jobs

# Add email functionality
rails g claude:views rails-mailers

# Add debugging tools
rails g claude:views rails-debugging

# Add API controller patterns (for building JSON APIs)
rails g claude:views rails-api-controllers

# Add pagination with Kaminari
rails g claude:views rails-pagination-kaminari
```

### Example 4: Custom Domain Skills

```bash
# You have specific business logic patterns
rails g claude:skill subscription-billing \
  --description="Stripe subscription and billing patterns" \
  --with-references \
  --template=model

# Edit the generated skill at:
# .claude/skills/subscription-billing/SKILL.md

# Add your domain-specific patterns, code examples, and best practices
```

## Configuration

### Global Configuration

Create an initializer to configure the gem:

```ruby
# config/initializers/rails_claude_skills.rb
RailsClaudeSkills.configure do |config|
  # Directory paths
  config.skills_path = ".claude/skills"
  config.agents_path = ".claude/agents"

  # Default model
  config.default_model = "sonnet"
end
```

### Per-Project Settings

The install generator creates a `.claude/settings.local.json` file with configuration based on your chosen preset:

**Example for basic preset:**
```json
{
  "skills": {
    "autoLoad": true,
    "path": ".claude/skills"
  },
  "agents": {
    "path": ".claude/agents",
    "default": "rails-developer"
  },
  "model": "sonnet",
  "project": "MyRailsApp",
  "rails_version": "7.1.3"
}
```

**Example for fullstack preset:**
```json
{
  "skills": {
    "autoLoad": true,
    "path": ".claude/skills"
  },
  "agents": {
    "path": ".claude/agents",
    "default": "fullstack-dev"
  },
  "model": "sonnet",
  "project": "MyRailsApp",
  "rails_version": "7.1.3"
}
```

The `default` agent is automatically set based on your chosen preset (basic → rails-developer, fullstack → fullstack-dev, api → api-dev).

## Directory Structure

After running `rails g claude:install`, your project will have:

```
your-rails-app/
├── .claude/
│   ├── settings.local.json          # Claude configuration
│   ├── README.md                     # Usage instructions
│   ├── skills/                       # Reusable knowledge modules
│   │   ├── rails-models/
│   │   │   ├── SKILL.md
│   │   │   └── references/          # Optional reference materials
│   │   ├── rails-controllers/
│   │   │   └── SKILL.md
│   │   └── rails-views/
│   │       └── SKILL.md
│   ├── commands/                     # Custom slash commands
│   │   ├── dbchange.md              # /dbchange command
│   │   ├── quality.md               # /quality command
│   │   └── turbo-feature.md         # /turbo-feature command
│   ├── rules/                        # Project guidelines
│   │   ├── code-style.md            # Ruby/Rails style rules
│   │   ├── testing.md               # Testing standards
│   │   └── database.md              # Database conventions
│   └── agents/                       # AI agent definitions
│       └── fullstack-dev.md
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/shoebtamboli/rails_claude_skills. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/shoebtamboli/rails_claude_skills/blob/main/CODE_OF_CONDUCT.md).

### How to Add New Skills

1. Create skill directory in `lib/generators/claude/skills_library/`
2. Write `SKILL.md` with proper frontmatter
3. Add references if needed
4. Test with generator
5. Submit PR

## Roadmap

### Current: Preparing for Initial Release (v0.1.0) 🚀

**Core Features (Complete)**
- [x] Gem structure and configuration system
- [x] Install generator with 3 presets (basic, fullstack, api)
- [x] Skill generator for custom skills
- [x] Agent generator for custom agents
- [x] Command generator for slash commands
- [x] Rule generator for project guidelines
- [x] Views generator to customize resources

**Content Library (Complete)**
- [x] 18 pre-built skills covering Rails, testing, authentication, background jobs, and more
- [x] 5 pre-built commands (quality, turbo-feature, dbchange, stimulus, create-pr)
- [x] 5 pre-built rules (code-style, testing, security, database, hotwire)
- [x] 3 pre-configured agents (rails-developer, fullstack-dev, api-dev)

**Documentation & Community (Complete)**
- [x] Comprehensive README with examples
- [x] Contributing guidelines with detailed instructions
- [x] Issue templates (bug report, feature request, question)
- [x] Code of Conduct
- [x] CI/CD pipeline (GitHub Actions)
- [x] Automated release workflow

**Status**: Ready for publication to RubyGems.org

### Future: Ecosystem Growth (v0.2.0+) 📋

**Planned Features**
- [ ] Serialization skill (rails-serializers for JSON:API, ActiveModel::Serializers)
- [ ] Additional popular gem integrations (Pundit, ActiveAdmin, Sidekiq, etc.)
- [ ] Skill dependency resolution and auto-installation
- [ ] Community skill repository and sharing
- [ ] Rails version detection and compatibility warnings
- [ ] Skill versioning and upgrade paths
- [ ] Interactive skill browser/explorer
- [ ] Skill testing framework
- [ ] Skill metrics and analytics

**Community Contributions Welcome**
We welcome contributions of new skills, commands, and rules! See [CONTRIBUTING.md](CONTRIBUTING.md) for details.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the RailsClaudeSkills project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/shoebtamboli/rails_claude_skills/blob/main/CODE_OF_CONDUCT.md).

---

**Happy Coding with AI! 🚀**
