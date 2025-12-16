# Rails Claude Skills Gem

**Project Name:** `rails_claude_skills`  
**Purpose:** A Rails generator gem that scaffolds Claude AI skills and agents for any Rails project, making AI-assisted development reusable and distributable.

## Table of Contents

- [Overview](#overview)
- [Motivation](#motivation)
- [Features](#features)
- [Installation & Usage](#installation--usage)
- [Architecture](#architecture)
- [Creating the Gem from Scratch](#creating-the-gem-from-scratch)
- [Generator Types](#generator-types)
- [Skill Schema](#skill-schema)
- [Examples](#examples)
- [Development Roadmap](#development-roadmap)

---

## Overview

`rails_claude_skills` is a Ruby gem that brings Rails generator conventions to Claude AI skills. Just like how Devise provides `rails g devise:install` and Kaminari provides `rails g kaminari:config`, this gem provides generators to scaffold AI context and knowledge for your Rails projects.

### What Problem Does It Solve?

- **Reusability**: Share Claude skills across multiple Rails projects
- **Team Collaboration**: Entire team gets consistent AI context
- **Maintainability**: Update skills in one place, distribute via gem updates
- **Convention**: Follows Rails patterns developers already know
- **Discoverability**: Makes best practices easily accessible to AI assistants

### Inspiration

This gem follows patterns from successful Rails ecosystem gems:

| Gem | Pattern Used | Applied to Claude Skills |
|-----|--------------|--------------------------|
| **Devise** | Generators, customizable views, initializers | Skill generators, customizable templates, configuration |
| **Kaminari** | Theme system, view templates | Skill presets, reference templates |
| **Rails itself** | Scaffold generators, conventions | Skill scaffolding, naming conventions |

---

## Motivation

### Current Problem

Claude skills are manually created per-project:
```
my-app-1/.claude/skills/rails-models/
my-app-2/.claude/skills/rails-models/  # Duplicated!
my-app-3/.claude/skills/rails-models/  # Duplicated again!
```

### With rails_claude_skills

```bash
# In any Rails project
gem 'rails_claude_skills'
rails g claude:install --preset=fullstack
# ✅ Instant AI context for your entire stack
```

---

## Features

### ✅ Core Features

- **One-Command Setup**: Initialize Claude skills in any Rails project
- **Modular Skills**: Generate only the skills you need
- **Preset Bundles**: Common skill combinations (fullstack, api, minimal)
- **Customizable Templates**: Override and customize skills like Devise views
- **Version Aware**: Adapts to Rails version (7+, 8+, etc.)
- **Multi-Framework**: Supports different ORMs, view engines, CSS frameworks
- **Progressive Disclosure**: Skills use 3-level context loading
- **Team Shareable**: Commit skills to version control for team consistency

### 🎯 Generator Types

1. **Installation Generator**: `rails g claude:install`
2. **Skill Generator**: `rails g claude:skill <name>`
3. **Agent Generator**: `rails g claude:agent <name>`
4. **Views Generator**: `rails g claude:views <skill>`
5. **Scaffold Generator**: `rails g claude:scaffold <context>`

---

## Installation & Usage

### Installation

```ruby
# Gemfile
gem 'rails_claude_skills', group: :development
```

```bash
bundle install
```

### Quick Start

```bash
# Initialize with default skills
rails g claude:install

# Or use a preset
rails g claude:install --preset=fullstack

# Generate specific skill
rails g claude:skill rails-models

# Create custom agent
rails g claude:agent backend-dev --skills=models,controllers,jobs

# Customize existing skill templates
rails g claude:views rails-models
```

---

## Architecture

### Directory Structure

After running `rails g claude:install`, your project will have:

```
your-rails-app/
├── .claude/
│   ├── settings.local.json          # Claude configuration
│   ├── agents/                       # Agent definitions
│   │   └── fullstack-dev.md
│   └── skills/                       # Skill modules
│       ├── rails-models/
│       │   ├── SKILL.md
│       │   └── references/
│       │       ├── validations.md
│       │       ├── associations.md
│       │       └── querying.md
│       ├── rails-controllers/
│       ├── rails-views/
│       └── tailwindcss/
└── ...
```

### Gem Structure

```
rails_claude_skills/
├── lib/
│   ├── rails_claude_skills.rb
│   ├── rails_claude_skills/
│   │   ├── version.rb
│   │   ├── configuration.rb
│   │   └── railtie.rb                # Hooks into Rails
│   └── generators/
│       └── claude/
│           ├── install/
│           │   ├── install_generator.rb
│           │   └── templates/
│           │       ├── settings.local.json
│           │       └── README.md
│           ├── skill/
│           │   ├── skill_generator.rb
│           │   └── templates/
│           │       └── skill_template.md.tt
│           ├── agent/
│           │   ├── agent_generator.rb
│           │   └── templates/
│           │       └── agent_template.md.tt
│           ├── views/
│           │   └── views_generator.rb
│           └── skills_library/          # Pre-built skills
│               ├── rails-models/
│               ├── rails-controllers/
│               ├── rails-views/
│               ├── rails-hotwire/
│               ├── rails-jobs/
│               ├── rails-mailers/
│               ├── rails-auth-devise/
│               ├── rspec-testing/
│               └── tailwindcss/
├── spec/
│   └── generators/
├── README.md
├── CHANGELOG.md
├── LICENSE.txt
└── rails_claude_skills.gemspec
```

---

## Creating the Gem from Scratch

### Step 1: Initialize the Gem

```bash
# Create gem structure
bundle gem rails_claude_skills --test=rspec

cd rails_claude_skills
```

This creates:
```
rails_claude_skills/
├── lib/rails_claude_skills.rb
├── lib/rails_claude_skills/version.rb
├── rails_claude_skills.gemspec
├── Gemfile
├── README.md
├── LICENSE.txt
└── spec/
```

### Step 2: Update Gemspec

Edit `rails_claude_skills.gemspec`:

```ruby
# rails_claude_skills.gemspec
require_relative "lib/rails_claude_skills/version"

Gem::Specification.new do |spec|
  spec.name = "rails_claude_skills"
  spec.version = RailsClaudeSkills::VERSION
  spec.authors = ["Your Name"]
  spec.email = ["your.email@example.com"]

  spec.summary = "Rails generators for Claude AI skills and agents"
  spec.description = "Scaffold reusable Claude AI skills and agents for Rails projects using familiar Rails generator patterns"
  spec.homepage = "https://github.com/yourusername/rails_claude_skills"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"

  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Runtime dependencies
  spec.add_dependency "rails", ">= 7.0"
  
  # Development dependencies
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "generator_spec", "~> 0.9"
end
```

### Step 3: Set Up Basic Structure

```bash
# Create directories
mkdir -p lib/rails_claude_skills
mkdir -p lib/generators/claude
mkdir -p spec/generators
```

### Step 4: Create Version File

```ruby
# lib/rails_claude_skills/version.rb
module RailsClaudeSkills
  VERSION = "0.1.0"
end
```

### Step 5: Create Main Library File

```ruby
# lib/rails_claude_skills.rb
require "rails_claude_skills/version"
require "rails_claude_skills/railtie" if defined?(Rails::Railtie)

module RailsClaudeSkills
  class Error < StandardError; end
  
  class << self
    attr_accessor :configuration
  end

  def self.configure
    self.configuration ||= Configuration.new
    yield(configuration)
  end

  class Configuration
    attr_accessor :skills_path, :agents_path, :default_model, :auto_load_skills

    def initialize
      @skills_path = ".claude/skills"
      @agents_path = ".claude/agents"
      @default_model = "sonnet"
      @auto_load_skills = true
    end
  end
end
```

### Step 6: Create Railtie (Rails Integration)

```ruby
# lib/rails_claude_skills/railtie.rb
module RailsClaudeSkills
  class Railtie < Rails::Railtie
    railtie_name :rails_claude_skills

    rake_tasks do
      load "tasks/claude_skills.rake"
    end
  end
end
```

### Step 7: Create Your First Generator

```ruby
# lib/generators/claude/install/install_generator.rb
require 'rails/generators'

module Claude
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path('templates', __dir__)
      
      class_option :preset, type: :string, default: "basic",
                   desc: "Preset bundle (basic, fullstack, api)"

      def create_claude_directory
        empty_directory ".claude"
        empty_directory ".claude/skills"
        empty_directory ".claude/agents"
      end

      def copy_settings
        template "settings.local.json", ".claude/settings.local.json"
      end

      def copy_readme
        template "README.md", ".claude/README.md"
      end

      def install_preset_skills
        case options[:preset]
        when "fullstack"
          install_fullstack_preset
        when "api"
          install_api_preset
        else
          install_basic_preset
        end
      end

      def show_readme
        readme "USAGE" if behavior == :invoke
      end

      private

      def install_basic_preset
        say "Installing basic preset...", :green
        # Copy basic skills
      end

      def install_fullstack_preset
        say "Installing fullstack preset...", :green
        # Copy fullstack skills
      end

      def install_api_preset
        say "Installing API preset...", :green
        # Copy API skills
      end
    end
  end
end
```

### Step 8: Create Generator Templates

```json
# lib/generators/claude/install/templates/settings.local.json
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
  "project": "<%= Rails.application.class.module_parent_name %>"
}
```

```markdown
# lib/generators/claude/install/templates/README.md
# Claude Skills for <%= Rails.application.class.module_parent_name %>

This directory contains Claude AI skills and agents for this Rails project.

## Structure

- `skills/` - Modular skill definitions
- `agents/` - Agent configurations that load multiple skills
- `settings.local.json` - Claude configuration

## Usage

Skills are automatically loaded when you use Claude in this project.

To customize a skill:
```bash
rails g claude:views <skill-name>
```

To create a new skill:
```bash
rails g claude:skill <skill-name>
```
```

### Step 9: Create Skill Library Templates

```markdown
# lib/generators/claude/skills_library/rails-models/SKILL.md
---
name: rails-models
description: ActiveRecord patterns, migrations, validations, callbacks, associations
---

# Rails Models (ActiveRecord)

[Full skill content here...]
```

### Step 10: Add Generator Tests

```ruby
# spec/generators/install_generator_spec.rb
require 'spec_helper'
require 'generator_spec'
require 'generators/claude/install/install_generator'

RSpec.describe Claude::Generators::InstallGenerator, type: :generator do
  destination File.expand_path("../../tmp", __FILE__)
  
  before(:all) do
    prepare_destination
    run_generator
  end

  it "creates .claude directory" do
    expect(destination_root).to have_structure {
      directory ".claude" do
        directory "skills"
        directory "agents"
        file "settings.local.json"
        file "README.md"
      end
    }
  end
end
```

### Step 11: Build and Test Locally

```bash
# Build the gem
gem build rails_claude_skills.gemspec

# Install locally
gem install ./rails_claude_skills-0.1.0.gem

# Test in a Rails app
cd /path/to/test/rails/app
bundle add rails_claude_skills --path=/path/to/rails_claude_skills
rails g claude:install
```

### Step 12: Publish to RubyGems

```bash
# First time setup
gem signin

# Build and push
gem build rails_claude_skills.gemspec
gem push rails_claude_skills-0.1.0.gem
```

---

## Generator Types

### 1. Install Generator

**Command:** `rails g claude:install [options]`

**Purpose:** Initial setup of Claude skills in a Rails project

**Options:**
- `--preset=basic` - Basic Rails skills (models, controllers, views)
- `--preset=fullstack` - Full stack (basic + hotwire, tailwindcss, testing)
- `--preset=api` - API-only (models, controllers, serializers, authentication)
- `--skip-agents` - Don't create default agents
- `--skip-readme` - Don't create README

**Generated Files:**
```
.claude/
├── settings.local.json
├── README.md
├── skills/
│   └── [preset-specific skills]
└── agents/
    └── [preset-specific agents]
```

**Example:**
```bash
rails g claude:install --preset=fullstack
```

### 2. Skill Generator

**Command:** `rails g claude:skill NAME [options]`

**Purpose:** Generate a new custom skill

**Options:**
- `--description=TEXT` - Skill description
- `--with-references` - Create references directory
- `--template=TYPE` - Use specific template (model, controller, generic)

**Generated Files:**
```
.claude/skills/NAME/
├── SKILL.md
└── references/
```

**Example:**
```bash
rails g claude:skill blog-publishing \
  --description="Blog-specific publishing patterns" \
  --with-references
```

### 3. Agent Generator

**Command:** `rails g claude:agent NAME [options]`

**Purpose:** Generate a new agent configuration

**Options:**
- `--skills=skill1,skill2` - Skills to auto-load
- `--model=MODEL` - Default model (sonnet, opus, haiku)
- `--description=TEXT` - Agent description

**Generated Files:**
```
.claude/agents/NAME.md
```

**Example:**
```bash
rails g claude:agent backend-dev \
  --skills=rails-models,rails-jobs,rspec-testing \
  --model=sonnet \
  --description="Backend development specialist"
```

### 4. Views Generator

**Command:** `rails g claude:views SKILL_NAME`

**Purpose:** Copy skill templates to project for customization (like `rails g devise:views`)

**Generated Files:**
```
.claude/skills/SKILL_NAME/
├── SKILL.md (editable copy)
└── references/ (editable copies)
```

**Example:**
```bash
rails g claude:views rails-models
# Now edit .claude/skills/rails-models/SKILL.md
```

### 5. Scaffold Generator

**Command:** `rails g claude:scaffold CONTEXT [options]`

**Purpose:** Generate complete skill + agent bundle for a specific context

**Options:**
- `--context=TYPE` - Context type (ecommerce, saas, blog, cms)

**Example:**
```bash
rails g claude:scaffold ecommerce
# Generates: payment skills, cart skills, inventory agent, etc.
```

---

## Skill Schema

### SKILL.md Format

Every skill follows this frontmatter format:

```markdown
---
name: skill-name
description: Brief description of what this skill covers
version: 1.0.0
rails_version: ">= 7.0"
dependencies:
  - other-skill-name
related_skills:
  - similar-skill
tags:
  - activerecord
  - database
  - models
---

# Skill Title

## Quick Reference

[Quick lookup tables, commands, patterns]

## Detailed Documentation

[Comprehensive guides, examples, best practices]

## Common Patterns

[Frequently used code patterns]

## Troubleshooting

[Common issues and solutions]

## References

[Links to external documentation]
```

### Agent Format

```markdown
---
name: agent-name
description: When to use this agent
model: sonnet
color: red
skills:
  - rails-models
  - rails-controllers
  - tailwindcss
---

You are a [role description]...

## Skills Integration

This agent auto-loads: [list]

## Core Expertise

[Specific expertise areas]

## Development Workflow

[Step-by-step workflow]
```

---

## Examples

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

### Example 2: API-Only Project

```bash
rails new api_app --api
cd api_app

bundle add rails_claude_skills
rails g claude:install --preset=api

# Generated skills: models, api-controllers, serializers, authentication
```

### Example 3: Custom Skill for Domain Logic

```bash
# You have specific business logic patterns
rails g claude:skill subscription-billing \
  --description="Stripe subscription and billing patterns" \
  --with-references

# Edit the generated skill
# .claude/skills/subscription-billing/SKILL.md
```

### Example 4: Team Customization

```bash
# Lead developer sets up and customizes
rails g claude:install --preset=fullstack
rails g claude:views rails-models  # Customize for team conventions

# Commit .claude/ to git
git add .claude/
git commit -m "Add Claude skills with team conventions"

# Other team members pull
git pull

# Everyone now has consistent AI context!
```

### Example 5: Update Skills from Gem

```bash
# Gem author releases new version with improved skills
bundle update rails_claude_skills

# Regenerate to get updates
rails g claude:install --preset=fullstack --force

# Or selectively update
rails g claude:skill rails-models --force
```

---

## Development Roadmap

### Phase 1: MVP (v0.1.0)
- [ ] Gem structure and setup
- [ ] Install generator with basic preset
- [ ] 5 core skills (models, controllers, views, routes, testing)
- [ ] 1 default agent (fullstack-dev)
- [ ] Basic documentation
- [ ] RSpec test coverage

### Phase 2: Enhancement (v0.2.0)
- [ ] Additional presets (api, minimal, fullstack)
- [ ] Skill generator for custom skills
- [ ] Agent generator
- [ ] Views generator (customization)
- [ ] 10+ pre-built skills
- [ ] Rails version detection
- [ ] Better templates with ERB variables

### Phase 3: Ecosystem (v0.3.0)
- [ ] Scaffold generator for contexts (ecommerce, saas, etc.)
- [ ] Integration with popular gems (Devise, Pundit, ActiveAdmin)
- [ ] Skill dependency resolution
- [ ] CLI for skill management
- [ ] Community skill repository
- [ ] Skill marketplace/registry

### Phase 4: Advanced (v1.0.0)
- [ ] Plugin architecture for third-party skills
- [ ] Skill versioning and updates
- [ ] Multi-framework support (Sinatra, Hanami)
- [ ] AI model-specific optimizations
- [ ] Performance metrics and analytics
- [ ] Team collaboration features

---

## Configuration

### Global Configuration

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
  
  # Custom skill sources (for private skill repos)
  config.skill_sources = [
    "https://github.com/your-org/custom-claude-skills"
  ]
end
```

### Per-Project Settings

```json
// .claude/settings.local.json
{
  "skills": {
    "autoLoad": true,
    "path": ".claude/skills",
    "enabled": [
      "rails-models",
      "rails-controllers",
      "tailwindcss"
    ]
  },
  "agents": {
    "path": ".claude/agents",
    "default": "fullstack-dev"
  },
  "model": "sonnet",
  "project": "MyRailsApp"
}
```

---

## Advanced Usage

### Creating Custom Skill Templates

```ruby
# lib/generators/claude/skill/templates/custom_template.md.tt
---
name: <%= skill_name %>
description: <%= skill_description %>
project: <%= Rails.application.class.module_parent_name %>
created_at: <%= Time.current.iso8601 %>
---

# <%= skill_name.titleize %>

## Overview

<%= skill_description %>

## Quick Reference

| Command | Purpose |
|---------|---------|
| TODO    | TODO    |

## Usage

...
```

### Version-Specific Skills

```ruby
# In generator
def copy_model_skill
  if rails_version >= Gem::Version.new('7.1')
    template "rails-models-7.1.md", ".claude/skills/rails-models/SKILL.md"
  else
    template "rails-models-7.0.md", ".claude/skills/rails-models/SKILL.md"
  end
end

def rails_version
  Gem::Version.new(Rails::VERSION::STRING)
end
```

### Skill Dependencies

```yaml
# In SKILL.md frontmatter
dependencies:
  - rails-models  # Must be loaded before this skill
related_skills:
  - rails-controllers  # Helpful but not required
```

---

## Testing the Gem

### Generator Tests

```ruby
# spec/generators/install_generator_spec.rb
require 'spec_helper'
require 'generator_spec'

RSpec.describe Claude::Generators::InstallGenerator do
  include GeneratorSpec::TestCase
  destination File.expand_path("../../../tmp", __FILE__)

  before(:all) do
    prepare_destination
    run_generator
  end

  it "creates .claude directory structure" do
    expect(File).to exist("#{destination_root}/.claude")
    expect(File).to exist("#{destination_root}/.claude/skills")
    expect(File).to exist("#{destination_root}/.claude/agents")
  end

  it "creates settings file" do
    expect(File).to exist("#{destination_root}/.claude/settings.local.json")
  end

  describe "with fullstack preset" do
    before(:all) do
      prepare_destination
      run_generator %w[--preset=fullstack]
    end

    it "installs fullstack skills" do
      expect(File).to exist("#{destination_root}/.claude/skills/rails-models")
      expect(File).to exist("#{destination_root}/.claude/skills/tailwindcss")
      expect(File).to exist("#{destination_root}/.claude/skills/rails-hotwire")
    end
  end
end
```

### Integration Tests

```ruby
# spec/integration/usage_spec.rb
RSpec.describe "Gem usage in Rails app" do
  it "can be installed and used" do
    # Test in actual Rails app
  end
end
```

---

## Publishing Checklist

Before publishing to RubyGems:

- [ ] Update version in `lib/rails_claude_skills/version.rb`
- [ ] Update `CHANGELOG.md`
- [ ] Run all tests: `bundle exec rspec`
- [ ] Build gem: `gem build rails_claude_skills.gemspec`
- [ ] Test gem locally in Rails app
- [ ] Update README with latest features
- [ ] Tag release in git: `git tag v0.1.0`
- [ ] Push to GitHub: `git push --tags`
- [ ] Publish to RubyGems: `gem push rails_claude_skills-0.1.0.gem`
- [ ] Announce release

---

## Contributing

### How to Add New Skills

1. Create skill directory in `lib/generators/claude/skills_library/`
2. Write `SKILL.md` with proper frontmatter
3. Add references if needed
4. Test with generator
5. Submit PR

### Skill Guidelines

- Follow the skill schema format
- Include practical examples
- Reference official documentation
- Keep progressive disclosure in mind
- Test in real projects

---

## Resources

### Gem Development
- [RubyGems Guides](https://guides.rubygems.org/)
- [Rails Generators Guide](https://guides.rubyonrails.org/generators.html)
- [Bundler Gem Development](https://bundler.io/guides/creating_gem.html)

### Inspiration
- [Devise](https://github.com/heartcombo/devise)
- [Kaminari](https://github.com/kaminari/kaminari)
- [Rails](https://github.com/rails/rails)

### Claude AI
- [Claude Documentation](https://docs.anthropic.com/claude/)
- [Claude Skills Format](https://docs.anthropic.com/)

---

## License

MIT License - See LICENSE.txt

---

## Support

- Issues: https://github.com/yourusername/rails_claude_skills/issues
- Discussions: https://github.com/yourusername/rails_claude_skills/discussions
- Email: your.email@example.com

---

**Happy Coding with AI! 🚀**
