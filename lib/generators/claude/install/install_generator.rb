# frozen_string_literal: true

require "rails/generators"

module Claude
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("templates", __dir__)

      class_option :preset, type: :string, default: "basic",
                            desc: "Preset bundle (basic, fullstack, api)"
      class_option :skip_agents, type: :boolean, default: false,
                                 desc: "Don't create default agents"
      class_option :skip_readme, type: :boolean, default: false,
                                 desc: "Don't create README"

      def create_claude_directory
        empty_directory ".claude"
        empty_directory ".claude/skills"
        empty_directory ".claude/agents" unless options[:skip_agents]
        empty_directory ".claude/commands"
        empty_directory ".claude/rules"
      end

      def copy_settings
        template "settings.local.json.tt", ".claude/settings.local.json"
      end

      def copy_readme
        template "README.md.tt", ".claude/README.md" unless options[:skip_readme]
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
        install_basic_skills_and_rules
        create_basic_agent unless options[:skip_agents]
      end

      def install_fullstack_preset
        say "Installing fullstack preset...", :green
        install_basic_skills_and_rules
        install_skill("rails-hotwire")
        install_skill("tailwindcss")
        install_skill("rspec-testing")
        install_command("quality")
        install_command("turbo-feature")
        install_command("stimulus")
        install_command("create-pr")
        install_rule("hotwire")
        install_rule("security")
        create_fullstack_agent unless options[:skip_agents]
      end

      def install_basic_skills_and_rules
        install_skill("rails-models")
        install_skill("rails-controllers")
        install_skill("rails-views")
        install_command("dbchange")
        install_rule("code-style")
        install_rule("testing")
        install_rule("database")
      end

      def install_api_preset
        say "Installing API preset...", :green
        install_skill("rails-models")
        install_skill("rails-api-controllers")
        install_skill("rails-auth-with-devise")
        install_skill("rspec-testing")
        install_command("dbchange")
        install_command("quality")
        install_rule("code-style")
        install_rule("testing")
        install_rule("security")
        install_rule("database")
        create_api_agent unless options[:skip_agents]
      end

      def install_skill(skill_name)
        skill_dir = ".claude/skills/#{skill_name}"
        empty_directory skill_dir

        skill_source = File.expand_path("../skills_library/#{skill_name}", __dir__)
        if File.directory?(skill_source)
          directory skill_source, skill_dir
        else
          create_file "#{skill_dir}/SKILL.md", default_skill_content(skill_name)
        end
      end

      def install_command(command_name)
        command_file = ".claude/commands/#{command_name}.md"
        command_source = File.expand_path("../commands_library/#{command_name}.md", __dir__)

        if File.exist?(command_source)
          copy_file command_source, command_file
        else
          create_file command_file, default_command_content(command_name)
        end
      end

      def install_rule(rule_name)
        rule_file = ".claude/rules/#{rule_name}.md"
        rule_source = File.expand_path("../rules_library/#{rule_name}.md", __dir__)

        if File.exist?(rule_source)
          copy_file rule_source, rule_file
        else
          create_file rule_file, default_rule_content(rule_name)
        end
      end

      def create_basic_agent
        template "agents/rails-developer.md.tt", ".claude/agents/rails-developer.md"
      end

      def create_fullstack_agent
        template "agents/fullstack-dev.md.tt", ".claude/agents/fullstack-dev.md"
      end

      def create_api_agent
        template "agents/api-dev.md.tt", ".claude/agents/api-dev.md"
      end

      def default_skill_content(skill_name)
        <<~SKILL
          ---
          name: #{skill_name}
          description: #{skill_name.titleize} skill
          version: 1.0.0
          ---

          # #{skill_name.titleize}

          ## Quick Reference

          This skill is not yet implemented.

          ## Usage

          To customize this skill:
          ```bash
          rails g claude:views #{skill_name}
          ```
        SKILL
      end

      def default_command_content(command_name)
        <<~COMMAND
          ---
          description: #{command_name.titleize} command
          allowed-tools: Bash, Read, Edit, Write
          ---

          ## #{command_name.titleize}

          Add your command instructions here.

          Use $ARGUMENTS to reference command arguments.
        COMMAND
      end

      def default_rule_content(rule_name)
        <<~RULE
          # #{rule_name.titleize} Rules

          Add your project rules and guidelines here.

          ## Overview

          Describe the purpose of these rules.

          ## Guidelines

          - Add specific guidelines
          - Include best practices
          - Document conventions
        RULE
      end

      def app_name
        Rails.application.class.module_parent_name
      rescue StandardError
        "MyApp"
      end

      def rails_version
        Rails::VERSION::STRING
      rescue StandardError
        "7.0"
      end
    end
  end
end
