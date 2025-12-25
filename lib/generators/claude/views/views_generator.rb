# frozen_string_literal: true

require "rails/generators"
require "fileutils"

module Claude
  module Generators
    class ViewsGenerator < Rails::Generators::NamedBase
      source_root File.expand_path("..", __dir__)

      class_option :type, type: :string, default: "skill",
                          desc: "Type of resource to copy (skill, command, rule)"

      def copy_resource_to_project
        case options[:type]
        when "command"
          copy_command
        when "rule"
          copy_rule
        else
          copy_skill
        end
      end

      private

      def copy_skill
        skill_source = "#{self.class.source_root}/skills_library/#{file_name}"
        skill_dest = ".claude/skills/#{file_name}"

        if File.directory?(skill_source)
          directory skill_source, skill_dest
          say "Copied skill '#{file_name}' to your project for customization", :green
          say "\nYou can now edit:", :blue
          say "  #{skill_dest}/SKILL.md"
          say "  #{skill_dest}/references/*" if File.directory?("#{skill_source}/references")
          say "\nChanges will override the gem's default version.\n", :yellow
        else
          say "Skill '#{file_name}' not found in skills library", :red
          say "\nAvailable skills:", :blue
          list_available_skills
        end
      end

      def copy_command
        command_source = "#{self.class.source_root}/commands_library/#{file_name}.md"
        command_dest = ".claude/commands/#{file_name}.md"

        if File.exist?(command_source)
          copy_file command_source, command_dest
          say "Copied command '#{file_name}' to your project for customization", :green
          say "\nYou can now edit:", :blue
          say "  #{command_dest}"
          say "\nChanges will override the gem's default version.\n", :yellow
        else
          say "Command '#{file_name}' not found in commands library", :red
          say "\nAvailable commands:", :blue
          list_available_commands
        end
      end

      def copy_rule
        rule_source = "#{self.class.source_root}/rules_library/#{file_name}.md"
        rule_dest = ".claude/rules/#{file_name}.md"

        if File.exist?(rule_source)
          copy_file rule_source, rule_dest
          say "Copied rule '#{file_name}' to your project for customization", :green
          say "\nYou can now edit:", :blue
          say "  #{rule_dest}"
          say "\nChanges will override the gem's default version.\n", :yellow
        else
          say "Rule '#{file_name}' not found in rules library", :red
          say "\nAvailable rules:", :blue
          list_available_rules
        end
      end

      def list_available_skills
        skills_dir = "#{self.class.source_root}/skills_library"
        if File.directory?(skills_dir)
          Dir.entries(skills_dir).reject { |d| d.start_with?(".") }.each do |skill|
            say "  - #{skill}"
          end
        else
          say "  No pre-built skills found"
        end
      end

      def list_available_commands
        commands_dir = "#{self.class.source_root}/commands_library"
        if File.directory?(commands_dir)
          Dir.entries(commands_dir).reject { |f| f.start_with?(".") }.each do |command|
            say "  - #{File.basename(command, ".md")}"
          end
        else
          say "  No pre-built commands found"
        end
      end

      def list_available_rules
        rules_dir = "#{self.class.source_root}/rules_library"
        if File.directory?(rules_dir)
          Dir.entries(rules_dir).reject { |f| f.start_with?(".") }.each do |rule|
            say "  - #{File.basename(rule, ".md")}"
          end
        else
          say "  No pre-built rules found"
        end
      end
    end
  end
end
