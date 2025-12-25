# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Rails Claude Skills is a Rails generator gem that scaffolds Claude AI skills and agents for Rails projects. It brings Rails generator conventions to Claude AI, making AI-assisted development reusable and distributable across teams and projects.

## Development Commands

### Testing
```bash
# Run all tests
rake spec

# Run tests with RSpec directly
bundle exec rspec

# Run specific test file
bundle exec rspec spec/path/to/file_spec.rb
```

### Code Quality
```bash
# Run RuboCop linter
bundle exec rubocop

# Auto-fix RuboCop issues
bundle exec rubocop -a
```

### Build and Install
```bash
# Build the gem
bundle exec rake build

# Install gem locally
bundle exec rake install

# Build and push to RubyGems (maintainers only)
bundle exec rake release
```

### Setup
```bash
# Initial setup after cloning
bin/setup
```

## CI/CD Pipeline

### GitHub Actions Workflows

**CI Workflow** (`.github/workflows/ci.yml`):
- Triggered on push to `main` and pull requests
- Runs RuboCop linting
- Tests against Ruby versions: 3.0, 3.1, 3.2, 3.3
- Tests against Rails versions: 7.0, 7.1, 7.2
- Builds gem artifact
- Matrix testing ensures compatibility across versions

**Release Workflow** (`.github/workflows/release.yml`):
- Triggered on version tags (e.g., `v0.2.0`)
- Builds and publishes gem to RubyGems
- Creates GitHub release with release notes
- Requires `RUBYGEMS_API_KEY` secret in repository settings

**Dependabot** (`.github/dependabot.yml`):
- Weekly updates for Bundler dependencies
- Weekly updates for GitHub Actions
- Groups RuboCop updates together

### Running CI Locally

```bash
# Run the same checks as CI
bundle exec rspec
bundle exec rubocop

# Test specific Rails version
RAILS_VERSION=7.2 bundle update
RAILS_VERSION=7.2 bundle exec rspec
```

### Release Process

1. Update version in `lib/rails_claude_skills/version.rb`
2. Update `CHANGELOG.md` with release notes
3. Commit changes: `git commit -am "Release v0.x.x"`
4. Create and push tag: `git tag v0.x.x && git push origin v0.x.x`
5. GitHub Actions will automatically build and publish the gem

## Architecture

### Core Components

1. **Module Structure** (`lib/rails_claude_skills.rb`)
   - Main module with configuration support
   - `RailsClaudeSkills.configure` block for global settings
   - Default paths: `.claude/skills` and `.claude/agents`
   - Default model: "sonnet"

2. **Generators** (`lib/generators/claude/`)
   - **InstallGenerator**: Creates `.claude/` directory with preset bundles (basic, fullstack, api)
   - **SkillGenerator**: Creates custom skills with templates (generic, model, controller, frontend)
   - **AgentGenerator**: Creates agents that combine multiple skills
   - **CommandGenerator**: Creates custom Claude Code commands (slash commands)
   - **RuleGenerator**: Creates project-specific rules with templates (generic, testing, security, performance)
   - **ContextGenerator**: Scaffolds complete domain setups (ecommerce, saas, blog, social, api, marketplace)
   - **ViewsGenerator**: Copies skills, commands, or rules from gem to project for customization

3. **Skills Library** (`lib/generators/claude/skills_library/`)
   - Pre-built skills stored as directories with `SKILL.md` and optional `references/`
   - Available skills: rails-models, rails-controllers, rails-views, rails-hotwire, tailwindcss,
     rspec-testing, rails-jobs, rails-mailers, rails-auth-with-devise, rails-debugging, rails-api-controllers

4. **Commands Library** (`lib/generators/claude/commands_library/`)
   - Pre-built commands stored as markdown files with YAML frontmatter
   - Available commands: quality, turbo-feature, dbchange, stimulus, create-pr
   - Commands have: description, argument-hint, allowed-tools

5. **Rules Library** (`lib/generators/claude/rules_library/`)
   - Pre-built rules stored as markdown files with optional YAML frontmatter
   - Available rules: code-style, testing, security, database, hotwire
   - Rules can be scoped to specific paths using frontmatter

6. **Railtie Integration** (`lib/rails_claude_skills/railtie.rb`)
   - Integrates gem with Rails application lifecycle
   - Auto-loads generators when gem is present

### Generator Presets

**Basic Preset**:
- Skills: rails-models, rails-controllers, rails-views
- Commands: dbchange
- Rules: code-style, testing, database

**Fullstack Preset**:
- Skills: Basic + rails-hotwire, tailwindcss, rspec-testing
- Commands: Basic + quality, turbo-feature, stimulus, create-pr
- Rules: Basic + hotwire, security

**API Preset**:
- Skills: rails-models, rails-api-controllers, rails-serializers, rails-authentication
- Commands: dbchange, quality
- Rules: code-style, testing, security, database

### Context Generator Design

The ContextGenerator (lib/generators/claude/context/context_generator.rb:15-49) defines six available contexts, each with:
- Description
- List of skills to install
- Associated agent name
- Template files in `lib/generators/claude/context/templates/contexts/<name>/`

Template structure for each context:
- `agent.md.tt` - Agent definition
- `README.md.tt` - Context documentation
- `models.md.tt` - Example model definitions

### Resource Structures

#### Skills
Each skill in the library follows this pattern:
```
skill-name/
├── SKILL.md          # Main skill content with frontmatter (name, description, version)
└── references/       # Optional: supporting files and examples
```

Skills use YAML frontmatter in `SKILL.md`:
```yaml
---
name: skill-name
description: Brief description
version: 1.0.0
tags: [tag1, tag2]
---
```

#### Commands
Commands are single markdown files with YAML frontmatter:
```yaml
---
description: Command description
argument-hint: [optional_args]
allowed-tools: Bash, Read, Edit, Write
---
```

#### Rules
Rules are single markdown files with optional YAML frontmatter for path scoping:
```yaml
---
paths: app/models/**/*,db/**/*
---
```

## Development Workflow

### Adding a New Skill

1. Create directory in `lib/generators/claude/skills_library/<skill-name>/`
2. Add `SKILL.md` with proper frontmatter (name, description, version)
3. Add `references/` directory if needed for examples
4. Update preset definitions in `install_generator.rb` if skill should be part of a preset
5. Test by running the install generator and verifying skill is copied correctly

### Adding a New Command

1. Create file in `lib/generators/claude/commands_library/<command-name>.md`
2. Add YAML frontmatter with description, argument-hint, and allowed-tools
3. Write command instructions using $ARGUMENTS or $1, $2, etc. for arguments
4. Update preset definitions in `install_generator.rb` if command should be part of a preset
5. Test with `rails g claude:views <command-name> --type=command`

### Adding a New Rule

1. Create file in `lib/generators/claude/rules_library/<rule-name>.md`
2. Add optional YAML frontmatter with paths for scoping
3. Write rule content with guidelines and best practices
4. Update preset definitions in `install_generator.rb` if rule should be part of a preset
5. Test with `rails g claude:views <rule-name> --type=rule`

### Adding a New Context

1. Add context definition to `AVAILABLE_CONTEXTS` hash in `context_generator.rb`
2. Create directory `lib/generators/claude/context/templates/contexts/<context-name>/`
3. Create template files:
   - `agent.md.tt` - Agent configuration
   - `README.md.tt` - Context documentation
   - `models.md.tt` - Example models (optional)
4. Test with `rails g claude:context <context-name>`

### Adding a New Generator

1. Create generator class in `lib/generators/claude/<name>/<name>_generator.rb`
2. Inherit from `Rails::Generators::Base` or `Rails::Generators::NamedBase`
3. Set source_root to templates directory
4. Define class options with Thor option syntax
5. Implement generator methods (executed in order defined)
6. Add templates in `lib/generators/claude/<name>/templates/`
7. Test generator with `rails g claude:<name>`

## Code Conventions

### RuboCop Configuration (.rubocop.yml)

- Target Ruby 3.0+
- String literals: double quotes enforced
- Line length: max 150 characters
- Method length: max 25 lines (generators exempt)
- ABC size: max 25 (generators exempt)
- Block length: unlimited for specs and generators
- Documentation requirement: disabled

### Generator Patterns

- Use `empty_directory` before creating files in a directory
- Use `template` for `.tt` files (ERB templates)
- Use `directory` to copy entire skill directories
- Use `say` for colored output: `:green` (success), `:blue` (info), `:yellow` (warning), `:red` (error)
- Check for existing files/directories before creating to support idempotent operations
- Provide helpful next steps after generator completes

### Template Variables

Common ERB variables available in `.tt` templates:
- `file_name` - Dasherized name from generator argument
- `app_name` - Rails application name (from `Rails.application.class.module_parent_name`)
- `rails_version` - Rails version string
- `options[:<option_name>]` - Access to command-line options

## Testing

Tests are in `spec/` directory using RSpec:
- `spec/generators/` - Generator tests
- `spec/rails_claude_skills_spec.rb` - Main module tests
- `spec/spec_helper.rb` - RSpec configuration

RSpec configuration (`.rspec`):
- Format: documentation
- Color output enabled
- Auto-requires spec_helper

## Critical Dependencies

- Ruby >= 3.0.0
- Rails >= 7.0

Development dependencies:
- rspec ~> 3.0
- rubocop ~> 1.60
- rubocop-rake ~> 0.6
- rubocop-rspec ~> 2.25

## Important Notes

### Generator Execution Order

Generator methods execute in the order they're defined in the class. This is critical for:
- Creating directories before files
- Installing dependencies before using them
- Validating inputs before processing

### Skill Installation Logic

The `install_skill` method (used by both InstallGenerator and ContextGenerator):
1. Creates `.claude/skills/<skill-name>` directory
2. Checks if skill exists in `lib/generators/claude/skills_library/`
3. If found, copies entire directory to project
4. If not found, creates placeholder SKILL.md or shows warning

### Context Generator Validation

ContextGenerator validates context name against `AVAILABLE_CONTEXTS` hash before proceeding. Invalid contexts cause early exit with helpful error message listing available options.

### Template Resolution

Rails generators look for templates in `source_root` directory. Use:
- `template(source, destination)` for ERB templates
- `copy_file(source, destination)` for non-ERB files
- `directory(source, destination)` for entire directories

## File Locations Reference

- **Generators**: `lib/generators/claude/`
- **Skills Library**: `lib/generators/claude/skills_library/`
- **Commands Library**: `lib/generators/claude/commands_library/`
- **Rules Library**: `lib/generators/claude/rules_library/`
- **Context Templates**: `lib/generators/claude/context/templates/contexts/`
- **Agent Templates**: `lib/generators/claude/install/templates/agents/`
- **Tests**: `spec/`
- **Version**: `lib/rails_claude_skills/version.rb`

## Generator Usage Examples

```bash
# Install with preset
rails g claude:install --preset=fullstack

# Create custom skill
rails g claude:skill my-custom-skill --with_references

# Create custom command
rails g claude:command deploy --description="Deploy to production" --argument-hint="[environment]"

# Create custom rule
rails g claude:rule api-design --paths="app/controllers/api/**/*" --template=security

# Copy pre-built resources for customization
rails g claude:views rails-models                    # Copy skill
rails g claude:views quality --type=command          # Copy command
rails g claude:views security --type=rule            # Copy rule
```
