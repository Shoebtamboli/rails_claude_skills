# Development Guide

## Setup

```bash
# Clone the repository
git clone https://github.com/shoebtamboli/rails_claude_skills.git
cd rails_claude_skills

# Install dependencies
bundle install

# Run tests
bundle exec rspec
```

## Testing Locally

### Option 1: Install Locally

```bash
# Build the gem
gem build rails_claude_skills.gemspec

# Install locally
gem install ./rails_claude_skills-0.1.0.gem

# Test in a Rails app
cd /path/to/test/rails/app
rails g claude:install
```

### Option 2: Use Path in Gemfile

```ruby
# In your test Rails app's Gemfile
gem 'rails_claude_skills', path: '/path/to/rails_claude_skills'
```

Then:

```bash
bundle install
rails g claude:install
```

### Option 3: Use Bundle Local

```bash
# In the gem directory
bundle install

# In your test Rails app
bundle config local.rails_claude_skills /path/to/rails_claude_skills
bundle install
rails g claude:install
```

## Testing the Generators

### Test Install Generator

```bash
# Basic preset
rails g claude:install

# Fullstack preset
rails g claude:install --preset=fullstack

# API preset
rails g claude:install --preset=api

# With options
rails g claude:install --preset=fullstack --skip-agents
```

### Test Skill Generator

```bash
# Basic skill
rails g claude:skill my-custom-skill

# With options
rails g claude:skill payment-processing \
  --description="Stripe payment patterns" \
  --with-references \
  --template=model
```

### Test Agent Generator

```bash
# Basic agent
rails g claude:agent my-agent

# With options
rails g claude:agent backend-specialist \
  --skills=rails-models,rails-jobs \
  --model=sonnet \
  --description="Backend development expert"
```

### Test Views Generator

```bash
# Copy skill for customization
rails g claude:views rails-models
```

## Verify Generated Files

After running generators, check:

```bash
# Verify directory structure
tree .claude/

# Verify settings
cat .claude/settings.local.json

# Verify skills
ls -la .claude/skills/

# Verify agents
ls -la .claude/agents/
```

## Making Changes

### Adding a New Skill

1. Create directory: `lib/generators/claude/skills_library/YOUR_SKILL/`
2. Create `SKILL.md` with frontmatter and content
3. Test: `rails g claude:views YOUR_SKILL`
4. Verify it appears in install generator

### Modifying Generators

1. Edit generator file in `lib/generators/claude/*/`
2. Edit templates in `lib/generators/claude/*/templates/`
3. Test the generator
4. Add/update tests in `spec/generators/`

### Running Tests

```bash
# Run all tests
bundle exec rspec

# Run specific test file
bundle exec rspec spec/generators/install_generator_spec.rb

# Run with documentation format
bundle exec rspec --format documentation
```

## Building and Releasing

### Build the Gem

```bash
gem build rails_claude_skills.gemspec
```

This creates `rails_claude_skills-0.1.0.gem`

### Install Locally

```bash
gem install ./rails_claude_skills-0.1.0.gem
```

### Publish to RubyGems (when ready)

```bash
# First time: sign in
gem signin

# Build and push
gem build rails_claude_skills.gemspec
gem push rails_claude_skills-0.1.0.gem
```

## Troubleshooting

### Generator Not Found

If `rails g claude:install` doesn't work:

1. Make sure gem is in Gemfile's development group
2. Run `bundle install`
3. Restart Rails console/server
4. Try `rails generate --help` to see if `claude:*` generators appear

### Templates Not Found

If templates are missing:

1. Check `lib/generators/claude/*/templates/` exists
2. Verify file names match template calls in generator
3. Check source_root is correctly set in generator

### Skill Not Found

If skill isn't available:

1. Check `lib/generators/claude/skills_library/SKILL_NAME/` exists
2. Verify `SKILL.md` file exists
3. Check install generator includes the skill

## Useful Commands

```bash
# List all generators
rails g --help | grep claude

# Show generator help
rails g claude:install --help
rails g claude:skill --help
rails g claude:agent --help

# Check gem version
gem list rails_claude_skills

# Uninstall gem
gem uninstall rails_claude_skills
```

## Code Quality

### Before Committing

```bash
# Run tests
bundle exec rspec

# Check for Ruby syntax errors
find lib -name "*.rb" -exec ruby -c {} \;

# Verify gemspec
gem build rails_claude_skills.gemspec

# Clean up
rm *.gem
```

## Next Steps

1. Add more comprehensive tests with generator_spec
2. Add more pre-built skills
3. Add Rails version detection
4. Improve error handling
5. Add skill dependency resolution
6. Create contribution guidelines
7. Set up CI/CD
8. Publish to RubyGems

---

**Happy Gem Development! 💎**
