# frozen_string_literal: true

require "rails/generators"

module Claude
  module Generators
    class CommandGenerator < Rails::Generators::NamedBase
      source_root File.expand_path("templates", __dir__)

      class_option :description, type: :string, default: nil,
                                 desc: "Command description"
      class_option :argument_hint, type: :string, default: nil,
                                   desc: "Argument hint for command usage"
      class_option :allowed_tools, type: :string, default: "Bash, Read, Edit, Write",
                                   desc: "Comma-separated list of allowed tools"

      def create_command_file
        template "command.md.tt", command_path
      end

      def show_instructions
        say "\nCommand '#{file_name}' created successfully!", :green
        say "\nLocation: #{command_path}", :blue
        say "\nUsage: /#{file_name}", :yellow
        say "\nNext steps:", :yellow
        say "  1. Edit #{command_path} to add your command logic"
        say "  2. Test with: /#{file_name}"
        say "  3. The command will be auto-loaded by Claude\n"
      end

      private

      def command_path
        ".claude/commands/#{file_name}.md"
      end

      def command_description
        options[:description] || "#{file_name.titleize} command"
      end

      def argument_hint
        options[:argument_hint] || "[arguments]"
      end

      def allowed_tools
        options[:allowed_tools]
      end
    end
  end
end
