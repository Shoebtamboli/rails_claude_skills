# frozen_string_literal: true

require "rails/generators"

module Claude
  module Generators
    class ContextGenerator < Rails::Generators::NamedBase
      source_root File.expand_path("templates", __dir__)

      class_option :skip_models, type: :boolean, default: false,
                                 desc: "Don't generate model examples"
      class_option :skip_agents, type: :boolean, default: false,
                                 desc: "Don't create context-specific agents"

      AVAILABLE_CONTEXTS = {
        "ecommerce" => {
          description: "E-commerce store with products, cart, orders, and payments",
          skills: %w[rails-models rails-controllers rails-views rails-jobs rails-mailers],
          agent: "ecommerce-dev"
        },
        "saas" => {
          description: "SaaS application with subscriptions, billing, and multi-tenancy",
          skills: %w[rails-models rails-controllers rails-views rails-auth-with-devise
                     rails-jobs rails-mailers],
          agent: "saas-dev"
        }
      }.freeze

      def validate_context
        return if AVAILABLE_CONTEXTS.key?(file_name)

        say "Context '#{file_name}' not found", :red
        say "\nAvailable contexts:", :blue
        list_available_contexts
        exit(1)
      end

      def show_context_info
        context = AVAILABLE_CONTEXTS[file_name]
        say "\n🚀 Setting up #{file_name.titleize} context", :green
        say "   #{context[:description]}", :cyan
        say "\n📦 Installing skills:", :blue
        context[:skills].each { |skill| say "   - #{skill}", :cyan }
      end

      def create_claude_directory
        empty_directory ".claude" unless File.directory?(".claude")
        empty_directory ".claude/skills" unless File.directory?(".claude/skills")
        empty_directory ".claude/agents" unless File.directory?(".claude/agents")
        empty_directory ".claude/contexts" unless File.directory?(".claude/contexts")
      end

      def install_context_skills
        context = AVAILABLE_CONTEXTS[file_name]
        context[:skills].each do |skill|
          install_skill(skill)
        end
      end

      def create_context_agent
        return if options[:skip_agents]

        context = AVAILABLE_CONTEXTS[file_name]
        agent_name = context[:agent]

        context_source = "#{self.class.source_root}/contexts/#{file_name}"
        agent_file = "#{context_source}/agent.md.tt"

        if File.exist?(agent_file)
          template agent_file, ".claude/agents/#{agent_name}.md"
        else
          create_generic_agent(agent_name, context[:skills])
        end
      end

      def create_context_readme
        context_source = "#{self.class.source_root}/contexts/#{file_name}"
        readme_file = "#{context_source}/README.md.tt"

        if File.exist?(readme_file)
          template readme_file, ".claude/contexts/#{file_name}-README.md"
        else
          create_generic_context_readme
        end
      end

      def create_model_examples
        return if options[:skip_models]

        context_source = "#{self.class.source_root}/contexts/#{file_name}"
        models_file = "#{context_source}/models.md.tt"

        return unless File.exist?(models_file)

        template models_file, ".claude/contexts/#{file_name}-models.md"
      end

      def show_next_steps
        say "\n✅ #{file_name.titleize} context successfully installed!", :green
        say "\n📖 Next steps:", :blue
        say "   1. Review context documentation:", :cyan
        say "      .claude/contexts/#{file_name}-README.md", :white

        unless options[:skip_models]
          say "\n   2. Check example models:", :cyan
          say "      .claude/contexts/#{file_name}-models.md", :white
        end

        say "\n   3. Start using the #{AVAILABLE_CONTEXTS[file_name][:agent]} agent", :cyan
        say "\n   4. Customize skills in .claude/skills/", :cyan
      end

      private

      def install_skill(skill_name)
        skill_dir = ".claude/skills/#{skill_name}"
        return if File.directory?(skill_dir) # Skip if already installed

        empty_directory skill_dir

        skill_source = File.expand_path("../../skills_library/#{skill_name}", __dir__)
        if File.directory?(skill_source)
          directory skill_source, skill_dir
        else
          say "   ⚠️  Skill '#{skill_name}' not found in library", :yellow
        end
      end

      def create_generic_agent(agent_name, skills)
        context = AVAILABLE_CONTEXTS[file_name]

        content = <<~AGENT
          ---
          name: #{agent_name}
          description: #{context[:description]}
          model: sonnet
          color: blue
          skills:
          #{skills.map { |s| "  - #{s}" }.join("\n")}
          ---

          # #{file_name.titleize} Development Agent

          Expert agent for building #{file_name} applications with Ruby on Rails.

          ## Context

          #{context[:description]}

          ## Skills Integration

          This agent auto-loads:
          #{skills.map { |s| "- **#{s}** - #{skill_description(s)}" }.join("\n")}

          ## Development Workflow

          1. **Understand Requirements** - Review business requirements and domain rules
          2. **Design Data Model** - Plan database schema and relationships
          3. **Build Backend** - Implement models, controllers, and business logic
          4. **Create Frontend** - Build views and user interactions
          5. **Add Background Jobs** - Set up async processing for emails, reports, etc.
          6. **Test Thoroughly** - Write comprehensive tests
          7. **Deploy** - Prepare for production deployment

          ## Best Practices

          - Follow Rails conventions
          - Keep controllers thin, models fat
          - Use background jobs for slow operations
          - Write tests for critical business logic
          - Optimize database queries with proper indexes
        AGENT

        create_file ".claude/agents/#{agent_name}.md", content
      end

      def create_generic_context_readme
        context = AVAILABLE_CONTEXTS[file_name]

        content = <<~README
          # #{file_name.titleize} Context

          #{context[:description]}

          ## Installed Skills

          #{context[:skills].map { |s| "- **#{s}**" }.join("\n")}

          ## Agent

          Use the **#{context[:agent]}** agent for #{file_name}-specific development.

          ## Customization

          You can customize any skill:

          ```bash
          rails g claude:views <skill-name>
          ```

          ## Learn More

          - [Rails Claude Skills Documentation](https://github.com/shoebtamboli/rails_claude_skills)
          - Check `.claude/contexts/#{file_name}-models.md` for example models
        README

        create_file ".claude/contexts/#{file_name}-README.md", content
      end

      def skill_description(skill_name)
        descriptions = {
          "rails-models" => "Database models and associations",
          "rails-controllers" => "HTTP controllers and routing",
          "rails-views" => "Templates and view helpers",
          "rails-api-controllers" => "RESTful API endpoints",
          "rails-auth-with-devise" => "User authentication",
          "rails-hotwire" => "Real-time interactions",
          "rails-jobs" => "Background processing",
          "rails-mailers" => "Email delivery",
          "tailwindcss" => "Utility-first styling",
          "rspec-testing" => "Testing framework"
        }
        descriptions[skill_name] || skill_name.titleize
      end

      def list_available_contexts
        AVAILABLE_CONTEXTS.each do |name, config|
          say "  #{name.ljust(15)} - #{config[:description]}"
        end
      end

      def app_name
        Rails.application.class.module_parent_name
      rescue StandardError
        "MyApp"
      end
    end
  end
end
