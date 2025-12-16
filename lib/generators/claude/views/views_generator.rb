# frozen_string_literal: true

require "rails/generators"
require "fileutils"

module Claude
  module Generators
    class ViewsGenerator < Rails::Generators::NamedBase
      source_root File.expand_path("..", __dir__)

      def copy_skill_to_project
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

      private

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
    end
  end
end
