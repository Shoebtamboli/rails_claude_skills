# Contributing to Rails Claude Skills

First off, thank you for considering contributing to Rails Claude Skills! It's people like you that make this gem better for the entire Rails community.

## Quick Links

- 🐛 [Report a Bug](https://github.com/Shoebtamboli/rails_claude_skills/issues/new?template=bug_report.yml)
- ✨ [Request a Feature](https://github.com/Shoebtamboli/rails_claude_skills/issues/new?template=feature_request.yml)
- ❓ [Ask a Question](https://github.com/Shoebtamboli/rails_claude_skills/issues/new?template=question.yml)
- 💬 [Join Discussions](https://github.com/Shoebtamboli/rails_claude_skills/discussions)
- 📖 [Read the Docs](https://github.com/Shoebtamboli/rails_claude_skills/blob/main/README.md)

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [How Can I Contribute?](#how-can-i-contribute)
  - [Reporting Bugs](#-reporting-bugs)
  - [Suggesting Features](#-suggesting-features)
  - [Asking Questions](#-asking-questions)
  - [Contributing Content](#contributing-content)
- [Development Setup](#development-setup)
- [Project Structure](#project-structure)
- [Adding New Content](#adding-new-content)
  - [Adding a New Skill](#adding-a-new-skill)
  - [Adding a New Command](#adding-a-new-command)
  - [Adding a New Rule](#adding-a-new-rule)
- [Testing Your Changes](#testing-your-changes)
- [Submitting Changes](#submitting-changes)
- [Style Guidelines](#style-guidelines)
- [Questions?](#questions)

## Code of Conduct

This project and everyone participating in it is governed by our [Code of Conduct](CODE_OF_CONDUCT.md). By participating, you are expected to uphold this code. Please report unacceptable behavior by [opening a confidential issue](https://github.com/Shoebtamboli/rails_claude_skills/issues/new?template=question.yml) or contacting the maintainers directly.

Key expectations:
- Be respectful and inclusive
- Welcome newcomers and help them learn
- Give and accept constructive feedback gracefully
- Focus on what's best for the community
- Show empathy and kindness

Please read the full [Code of Conduct](CODE_OF_CONDUCT.md) for detailed guidelines.

## How Can I Contribute?

There are many ways to contribute to Rails Claude Skills:

### 🐛 Reporting Bugs

Found a bug? Help us fix it!

**[Create a Bug Report →](https://github.com/Shoebtamboli/rails_claude_skills/issues/new?template=bug_report.yml)**

Our bug report template will guide you through providing all the necessary information:
- Steps to reproduce the issue
- Expected vs actual behavior
- Environment details (Ruby, Rails, gem versions)
- Relevant code snippets or error messages

Before submitting, please search existing issues to avoid duplicates.

### ✨ Suggesting Features

Have an idea for a new feature or enhancement?

**[Request a Feature →](https://github.com/Shoebtamboli/rails_claude_skills/issues/new?template=feature_request.yml)**

The feature request template helps you describe:
- The problem you're trying to solve
- Your proposed solution
- Use cases and benefits
- Examples from other tools

We especially welcome suggestions for:
- New skills for popular gems or Rails patterns
- New commands for common workflows
- New rules for best practices
- Improvements to existing generators

### ❓ Asking Questions

Need help or want to discuss something?

**[Ask a Question →](https://github.com/Shoebtamboli/rails_claude_skills/issues/new?template=question.yml)**

Or join the conversation in [GitHub Discussions](https://github.com/Shoebtamboli/rails_claude_skills/discussions)!

### Contributing Content

The easiest way to contribute! We welcome:

1. **New Skills** - Rails patterns, gems, best practices
2. **New Commands** - Useful slash commands for common workflows
3. **New Rules** - Project guidelines and conventions
4. **Improved Documentation** - Clearer examples, better explanations
5. **Bug Fixes** - Fixing issues in existing generators

## Development Setup

### 1. Fork and Clone

```bash
# Fork the repository on GitHub, then:
git clone https://github.com/YOUR-USERNAME/rails_claude_skills.git
cd rails_claude_skills
```

### 2. Install Dependencies

```bash
bundle install
```

### 3. Run Tests

```bash
bundle exec rspec
bundle exec rubocop
```

### 4. Create a Branch

```bash
git checkout -b feature/my-new-skill
# or
git checkout -b fix/generator-bug
```

## Project Structure

```
rails_claude_skills/
├── lib/
│   ├── generators/claude/
│   │   ├── install/              # Install generator
│   │   ├── skill/                # Skill generator
│   │   ├── agent/                # Agent generator
│   │   ├── command/              # Command generator
│   │   ├── rule/                 # Rule generator
│   │   ├── views/                # Views generator
│   │   ├── skills_library/       # Pre-built skills
│   │   ├── commands_library/     # Pre-built commands
│   │   └── rules_library/        # Pre-built rules
│   └── rails_claude_skills/
│       ├── version.rb
│       └── railtie.rb
├── spec/                         # Tests
├── CHANGELOG.md
├── CLAUDE.md                     # Internal documentation
└── README.md
```

## Adding New Content

### Adding a New Skill

Skills are the most common contribution. Here's how:

**1. Create the skill directory:**

```bash
mkdir -p lib/generators/claude/skills_library/my-new-skill
```

**2. Create SKILL.md with frontmatter:**

```markdown
---
name: my-new-skill
description: Brief description of what this skill covers
version: 1.0.0
tags:
  - relevant
  - tags
---

# My New Skill

## Quick Reference

| Pattern | Example |
|---------|---------|
| Key pattern | `code example` |

## Overview

Explain what this skill covers and when to use it.

## Common Patterns

### Pattern Name

```ruby
# Code example
class Example
  # ...
end
```

## Best Practices

- Guideline 1
- Guideline 2

## Common Pitfalls

- What to avoid
- Why it matters
```

**3. (Optional) Add reference files:**

```bash
mkdir lib/generators/claude/skills_library/my-new-skill/references
# Add example files, templates, etc.
```

**4. Test it:**

```bash
# In a test Rails app
rails g claude:views my-new-skill
cat .claude/skills/my-new-skill/SKILL.md
```

**5. Add to a preset (if appropriate):**

Edit `lib/generators/claude/install/install_generator.rb`:

```ruby
def install_fullstack_preset
  # ... existing skills ...
  install_skill("my-new-skill")  # Add here
end
```

### Adding a New Command

**1. Create the command file:**

```bash
touch lib/generators/claude/commands_library/my-command.md
```

**2. Add content with frontmatter:**

```markdown
---
description: What this command does
argument-hint: [optional_args]
allowed-tools: Bash, Read, Edit, Write
---

## My Command

Detailed instructions for Claude on what this command should do.

### Usage

```
/my-command [arguments]
```

### Arguments

- `$ARGUMENTS` - All arguments as a string
- `$1` - First argument
- `$2` - Second argument

### Example

When user runs `/my-command production`:
1. First step
2. Second step
3. Final step
```

**3. Test it:**

```bash
rails g claude:views my-command --type=command
cat .claude/commands/my-command.md
```

### Adding a New Rule

**1. Create the rule file:**

```bash
touch lib/generators/claude/rules_library/my-rule.md
```

**2. Add content (frontmatter optional):**

```markdown
---
paths: app/specific/**/*
---

# My Rule

## Purpose

Explain what these rules enforce and why.

## Guidelines

- Specific guideline 1
- Specific guideline 2
- Specific guideline 3

## Examples

### Good
```ruby
# Example of following the rule
```

### Bad
```ruby
# Example of violating the rule
```

## Rationale

Why these rules matter for the project.
```

**3. Test it:**

```bash
rails g claude:views my-rule --type=rule
cat .claude/rules/my-rule.md
```

## Testing Your Changes

### Running Tests

```bash
# Run all tests
bundle exec rspec

# Run specific test
bundle exec rspec spec/rails_claude_skills_spec.rb

# Run linter
bundle exec rubocop

# Auto-fix style issues
bundle exec rubocop -a
```

### Manual Testing

**Test in a real Rails app:**

```bash
# Create test Rails app
rails new test-app
cd test-app

# Add your local gem to Gemfile
echo "gem 'rails_claude_skills', path: '/path/to/your/rails_claude_skills'" >> Gemfile
bundle install

# Test generators
rails g claude:install --preset=fullstack
rails g claude:skill test-skill
rails g claude:views my-new-skill
```

### What to Test

- ✅ Generator creates expected files
- ✅ Files have correct content
- ✅ Frontmatter is valid YAML
- ✅ No typos or formatting issues
- ✅ Examples actually work
- ✅ Follows existing patterns

## Submitting Changes

### 1. Update CHANGELOG.md

Add your changes to the `[Unreleased]` section of CHANGELOG.md:

```markdown
## [Unreleased]

### Added
- New skill: rails-action-mailer

### Fixed
- Install generator typo in basic preset

### Changed
- Simplified skill generator templates
```

Use these categories:
- **Added** - New features, skills, commands, rules
- **Changed** - Changes to existing functionality
- **Deprecated** - Soon-to-be removed features
- **Removed** - Removed features
- **Fixed** - Bug fixes
- **Security** - Security improvements

### 2. Commit Your Changes

```bash
# Stage your changes
git add .

# Commit with a clear message
git commit -m "Add skill for ActionMailer patterns"
```

**Good commit messages:**
- `Add skill: rails-action-mailer`
- `Fix: Install generator typo in basic preset`
- `Docs: Improve README installation section`
- `Refactor: Simplify skill generator templates`

### 3. Push to Your Fork

```bash
git push origin feature/my-new-skill
```

### 4. Create Pull Request

- Go to the original repository on GitHub
- Click "Pull Request"
- Select your branch
- Fill in the PR template:

```markdown
## Description
Brief description of what this PR does

## Type of Change
- [ ] New skill/command/rule
- [ ] Bug fix
- [ ] Enhancement to existing content
- [ ] Documentation improvement

## Checklist
- [ ] I've tested this locally in a Rails app
- [ ] RuboCop passes (`bundle exec rubocop`)
- [ ] Tests pass (`bundle exec rspec`)
- [ ] I've updated CHANGELOG.md (if needed)
- [ ] Documentation is clear and accurate

## Screenshots (if applicable)
Show the generated files or output
```

### 5. Respond to Feedback

- Be open to suggestions
- Make requested changes promptly
- Ask questions if anything is unclear
- Be patient - reviews take time

## Style Guidelines

### Ruby Code

Follow the existing `.rubocop.yml` configuration:

- Use double quotes for strings
- 2-space indentation
- Max line length: 150 characters
- Descriptive variable names

### Markdown (Skills, Commands, Rules)

```markdown
# Clear headings hierarchy
## Use sentence case
### Not Title Case

- Lists with proper grammar
- One idea per bullet point
- End with periods if complete sentences

Code blocks with language specified:
```ruby
# Always specify the language
class Example
end
```

### YAML Frontmatter

```yaml
---
# Use lowercase-with-dashes for names
name: my-skill-name

# Clear, concise descriptions
description: Brief description under 80 chars

# Semantic versioning
version: 1.0.0

# Relevant, searchable tags
tags:
  - activerecord
  - database
---
```

### File Naming

- Skills: `lib/generators/claude/skills_library/skill-name/`
- Commands: `lib/generators/claude/commands_library/command-name.md`
- Rules: `lib/generators/claude/rules_library/rule-name.md`
- Use kebab-case (dashes, not underscores)

## Content Guidelines

### Quality Standards

**Skills should:**
- ✅ Focus on one topic/gem/pattern
- ✅ Include Quick Reference table
- ✅ Provide working code examples
- ✅ Explain the "why" not just "what"
- ✅ Cover common pitfalls
- ✅ Be maintained (update with Rails versions)

**Commands should:**
- ✅ Solve a specific workflow problem
- ✅ Have clear argument handling
- ✅ Include usage examples
- ✅ Specify allowed tools

**Rules should:**
- ✅ Be specific and actionable
- ✅ Include examples (good vs bad)
- ✅ Explain the rationale
- ✅ Be scoped to relevant paths (if applicable)

### What We're Looking For

**Great contributions:**
- 🎯 Solve real problems developers face
- 📚 Well-documented with examples
- 🧪 Tested in actual Rails apps
- 🎨 Follow existing patterns
- 💡 Include rationale/reasoning

**Avoid:**
- ❌ Overly opinionated content
- ❌ Copy-pasted from docs without context
- ❌ Outdated or deprecated patterns
- ❌ Overly complex examples
- ❌ Duplicate content

## Questions?

- 💬 Open a discussion on GitHub
- 🐛 Create an issue for bugs
- 📧 Reach out to maintainers
- 📖 Check existing skills for examples

## Recognition

Contributors will be:
- Listed in CHANGELOG.md
- Credited in release notes
- Added to README contributors section
- Appreciated in the Rails community! 🎉

---

Thank you for contributing to Rails Claude Skills! 🚀
