# Rails Claude Skills

[![Gem Version](https://badge.fury.io/rb/rails_claude_skills.svg)](https://badge.fury.io/rb/rails_claude_skills)

A Rails generator gem that scaffolds Claude AI skills and agents for any Rails project, making AI-assisted development reusable and distributable.

## What is This?

`rails_claude_skills` brings Rails generator conventions to Claude AI skills. Just like how Devise provides `rails g devise:install` and Kaminari provides `rails g kaminari:config`, this gem provides generators to scaffold AI context and knowledge for your Rails projects.

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
│   ├── skills/
│   │   ├── rails-models/
│   │   ├── rails-controllers/
│   │   └── rails-views/
│   └── agents/
│       └── basic-dev.md
```

### 2. Use the Skills with Claude

The skills are automatically loaded when you use Claude AI in your project. Claude will have deep knowledge of:
- Rails patterns and conventions
- ActiveRecord best practices
- Controller and routing patterns
- View helpers and templates
- And more based on your chosen preset

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

| Preset | Skills Included |
|--------|----------------|
| **basic** | rails-models, rails-controllers, rails-views |
| **fullstack** | basic + rails-hotwire, tailwindcss, rspec-testing |
| **api** | rails-models, rails-api-controllers, rails-serializers, rails-authentication (coming soon) |

**Note:** You can manually add additional skills like `rails-jobs`, `rails-mailers`, `rails-auth-with-devise`, and `rails-debugging` using the skill generator after installation.

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

### Context Generator

Scaffold a complete domain-specific setup with pre-configured skills, agents, and example models:

```bash
rails g claude:context CONTEXT_NAME [options]
```

**Options:**
- `--skip-models` - Don't generate model examples
- `--skip-agents` - Don't create context-specific agents

**Available Contexts:**

| Context | Description | Skills Included |
|---------|-------------|-----------------|
| **ecommerce** | E-commerce store | Products, cart, orders, payments |
| **saas** | SaaS application | Subscriptions, billing, multi-tenancy, teams |
| **blog** | Blog platform | Posts, comments, tags, authors |
| **social** | Social network | Users, posts, follows, feeds |
| **api** | JSON API backend | API controllers, authentication, versioning |
| **marketplace** | Two-sided marketplace | Buyers, sellers, transactions |

**Examples:**

```bash
# Set up e-commerce context
rails g claude:context ecommerce

# Set up SaaS context without model examples
rails g claude:context saas --skip-models

# Set up API backend context
rails g claude:context api
```

### Views Generator

Customize an existing skill by copying it to your project:

```bash
rails g claude:views SKILL_NAME
```

This copies the skill from the gem to your project, allowing you to customize it for your team's specific needs.

**Example:**

```bash
# Customize the rails-models skill
rails g claude:views rails-models

# Now edit .claude/skills/rails-models/SKILL.md
# Your changes will override the gem's default version
```

## Pre-Built Skills

The gem includes these pre-built skills:

### Core Rails
- **rails-models** - ActiveRecord patterns, migrations, validations, callbacks, associations
- **rails-controllers** - Controller actions, routing, REST conventions, filters
- **rails-views** - ERB templates, helpers, layouts, partials

### Full-Stack Development
- **rails-hotwire** - Turbo Drive, Turbo Frames, Turbo Streams, Stimulus
- **tailwindcss** - TailwindCSS utility-first styling
- **rspec-testing** - RSpec testing patterns and best practices

### Background Processing & Communication
- **rails-jobs** - Background jobs with SolidQueue, SolidCache, SolidCable (enforces TEAM RULE #1: NEVER Sidekiq/Redis)
- **rails-mailers** - ActionMailer for transactional and notification emails with async delivery

### Authentication & Authorization
- **rails-auth-with-devise** - Complete authentication setup with Devise, including OmniAuth and API auth
- **rails-authorization-cancancan** - Authorization and permissions management with CanCanCan, including RBAC, multi-tenancy, and API authorization

### Debugging
- **rails-debugging** - Rails-specific debugging tools and systematic debugging process

### API Development
- **rails-api-controllers** - RESTful API controllers, versioning, authentication, rate limiting, CORS, pagination, and API testing

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
```

### Example 4: Quick Start with Context Scaffolding

```bash
# Starting a SaaS project? Use the SaaS context
rails new my_saas_app
cd my_saas_app

# Add the gem
echo "gem 'rails_claude_skills', group: :development" >> Gemfile
bundle install

# Scaffold complete SaaS context
rails g claude:context saas

# This creates:
# - All necessary skills (models, auth, jobs, mailers)
# - saas-dev agent optimized for SaaS development
# - Example models (Account, Subscription, Plan, Membership)
# - Documentation with implementation guide

# Now you have everything to build a SaaS app!
```

### Example 5: Custom Domain Skills

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
  
  # Auto-load all skills
  config.auto_load_skills = true
end
```

### Per-Project Settings

The gem creates a `.claude/settings.local.json` file:

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
  "project": "MyRailsApp"
}
```

## Directory Structure

After running `rails g claude:install`, your project will have:

```
your-rails-app/
├── .claude/
│   ├── settings.local.json          # Claude configuration
│   ├── README.md                     # Usage instructions
│   ├── agents/                       # Agent definitions
│   │   └── fullstack-dev.md
│   └── skills/                       # Skill modules
│       ├── rails-models/
│       │   └── SKILL.md
│       ├── rails-controllers/
│       │   └── SKILL.md
│       └── rails-views/
│           └── SKILL.md
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

### Phase 1: MVP (v0.1.0) ✅
- [x] Gem structure and setup
- [x] Install generator with basic preset
- [x] 5 core skills (models, controllers, views, hotwire, tailwindcss)
- [x] Agent generator
- [x] Skill generator
- [x] Views generator
- [x] Basic documentation

### Phase 2: Enhancement (v0.2.0) 🚧 In Progress
- [x] RSpec testing skill with comprehensive patterns
- [x] Authentication skill (rails-auth-with-devise)
- [x] Authorization skill (rails-authorization-cancancan)
- [x] Background jobs skill (rails-jobs with SolidQueue)
- [x] Email delivery skill (rails-mailers)
- [x] Debugging tools skill (rails-debugging)
- [x] API controller patterns skill (rails-api-controllers)
- [ ] Serialization skill (rails-serializers)
- [ ] Rails version detection
- [ ] Improved templates
- [ ] Better error handling
- [ ] More comprehensive tests

### Phase 3: Ecosystem (v0.3.0) 🚧 In Progress
- [x] Context generator for domain-specific scaffolding (ecommerce, saas, blog, social, api, marketplace)
- [x] Integration with popular gems (Devise, CanCanCan)
- [ ] Skill dependency resolution
- [ ] Community skill repository
- [ ] Plugin system for third-party contexts

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the RailsClaudeSkills project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/shoebtamboli/rails_claude_skills/blob/main/CODE_OF_CONDUCT.md).

---

**Happy Coding with AI! 🚀**
