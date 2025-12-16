# frozen_string_literal: true

require "rails/generators"

module Claude
  module Generators
    class AgentGenerator < Rails::Generators::NamedBase
      source_root File.expand_path("templates", __dir__)

      class_option :skills, type: :array, default: [],
                            desc: "Skills to auto-load (comma-separated)"
      class_option :model, type: :string, default: "sonnet",
                           desc: "Default model (sonnet, opus, haiku)"
      class_option :description, type: :string, default: nil,
                                 desc: "Agent description"
      class_option :color, type: :string, default: "blue",
                           desc: "Agent color (for UI)"

      def create_agents_directory
        empty_directory ".claude/agents"
      end

      def create_agent_file
        template "agent.md.tt", agent_path
      end

      def show_instructions
        say "\nAgent '#{file_name}' created successfully!", :green
        say "\nLocation: #{agent_path}", :blue
        say "\nNext steps:", :yellow
        say "  1. Edit #{agent_path} to customize the agent"
        say "  2. Set as default in .claude/settings.local.json (optional)"
        say "  3. Use this agent when working on specific tasks\n"
      end

      private

      def agent_path
        ".claude/agents/#{file_name}.md"
      end

      def agent_description
        options[:description] || "Custom agent for #{file_name.titleize}"
      end

      def agent_skills
        if options[:skills].any?
          options[:skills]
        else
          %w[rails-models rails-controllers]
        end
      end

      def agent_model
        options[:model]
      end

      def agent_color
        options[:color]
      end

      def skills_list
        agent_skills.map { |skill| "  - #{skill}" }.join("\n")
      end

      def skills_description
        agent_skills.map { |skill| "**#{skill}**" }.join(", ")
      end
    end
  end
end
