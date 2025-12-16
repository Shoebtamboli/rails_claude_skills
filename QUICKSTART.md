# Quick Start Guide

## Installation

### 1. Add to Your Rails Project

Add to your `Gemfile`:

```ruby
group :development do
  gem 'rails_claude_skills'
end
```

Then run:

```bash
bundle install
```

### 2. Initialize Claude Skills

Choose a preset based on your project type:

#### Option A: Basic Rails (MVC)

```bash
rails g claude:install
```

This installs:
- ✅ rails-models (ActiveRecord, migrations, validations)
- ✅ rails-controllers (routing, actions, REST)
- ✅ rails-views (ERB, helpers, partials)
- ✅ basic-dev agent

#### Option B: Full-Stack (Hotwire + Tailwind)

```bash
rails g claude:install --preset=fullstack
```

This installs everything from Basic plus:
- ✅ rails-hotwire (Turbo, Stimulus)
- ✅ tailwindcss (utility CSS)
- ✅ fullstack-dev agent

#### Option C: API-Only

```bash
rails g claude:install --preset=api
```

This installs:
- ✅ rails-models
- ✅ rails-api-controllers
- ✅ rails-serializers
- ✅ rails-authentication
- ✅ api-dev agent

### 3. Verify Installation

Check what was created:

```bash
ls -la .claude/
```

You should see:
```
.claude/
├── settings.local.json
├── README.md
├── agents/
│   └── [your-preset]-dev.md
└── skills/
    ├── rails-models/
    ├── rails-controllers/
    └── ...
```

## Using the Skills

The skills are automatically available when you use Claude AI in your project. Claude will now have deep knowledge of Rails patterns and can:

- Generate models with proper validations and associations
- Create controllers following REST conventions
- Build views with Hotwire and Tailwind (if fullstack preset)
- Suggest best practices and common patterns
- Help debug issues with context-aware solutions

## Customization

### Create a Custom Skill

For domain-specific patterns:

```bash
rails g claude:skill subscription-billing \
  --description="Stripe subscription patterns" \
  --with-references \
  --template=model
```

Edit `.claude/skills/subscription-billing/SKILL.md` and add your patterns.

### Customize Existing Skills

Override gem skills with your team's conventions:

```bash
rails g claude:views rails-models
```

Now edit `.claude/skills/rails-models/SKILL.md` - your changes will take precedence.

### Create Custom Agents

Combine skills for specific tasks:

```bash
rails g claude:agent backend-specialist \
  --skills=rails-models,rails-jobs,rspec-testing \
  --model=sonnet \
  --description="Backend development expert"
```

## Example Workflows

### Scenario 1: Building a Blog

```bash
# 1. Initialize with fullstack preset
rails g claude:install --preset=fullstack

# 2. Ask Claude to help you build features
# Claude now knows:
#   - How to create models with associations
#   - How to build Hotwire-powered views
#   - How to style with TailwindCSS
#   - Rails best practices
```

### Scenario 2: Building an API

```bash
# 1. Initialize with API preset
rails g claude:install --preset=api

# 2. Create custom skill for your API patterns
rails g claude:skill api-versioning \
  --description="API versioning strategies"

# 3. Ask Claude to help build your API
# Claude now understands API-specific patterns
```

### Scenario 3: Team Collaboration

```bash
# Lead developer:
rails g claude:install --preset=fullstack
rails g claude:views rails-models  # Customize with team standards
git add .claude/
git commit -m "Add Claude skills with team conventions"
git push

# Other developers:
git pull
# Now everyone has the same AI context!
```

## Available Commands

### List All Generators

```bash
rails g --help | grep claude
```

### Get Help for Specific Generator

```bash
rails g claude:install --help
rails g claude:skill --help
rails g claude:agent --help
rails g claude:views --help
```

## Troubleshooting

### Generator Not Found

```bash
# Make sure gem is in Gemfile
bundle install

# Restart spring if using
spring stop

# Try again
rails g claude:install
```

### Skills Not Loading

1. Check `.claude/settings.local.json` exists
2. Verify `autoLoad: true`
3. Check skill directories exist in `.claude/skills/`

### Customization Not Working

When you run `rails g claude:views SKILL_NAME`, the skill is copied to your project. Your local version in `.claude/skills/` will override the gem's version.

## Next Steps

1. ✅ Install the gem
2. ✅ Initialize with a preset
3. ✅ Start using Claude with enhanced Rails knowledge
4. 📝 Create custom skills for your domain
5. 🔧 Customize skills for your team
6. 🚀 Share with your team via git

## Support

- 📖 Full Documentation: [README.md](README.md)
- 🐛 Issues: https://github.com/shoebtamboli/rails_claude_skills/issues
- 💡 Discussions: https://github.com/shoebtamboli/rails_claude_skills/discussions

---

**Happy Coding with AI! 🚀**
