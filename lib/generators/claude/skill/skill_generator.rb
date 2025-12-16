# frozen_string_literal: true

require "rails/generators"

module Claude
  module Generators
    class SkillGenerator < Rails::Generators::NamedBase
      source_root File.expand_path("templates", __dir__)

      class_option :description, type: :string, default: nil,
                                 desc: "Skill description"
      class_option :with_references, type: :boolean, default: false,
                                     desc: "Create references directory"
      class_option :template, type: :string, default: "generic",
                              desc: "Template type (generic, model, controller, frontend)"

      def create_skill_directory
        empty_directory skill_path
      end

      def create_skill_file
        template "SKILL.md.tt", "#{skill_path}/SKILL.md"
      end

      def create_references_directory
        return unless options[:with_references]

        empty_directory "#{skill_path}/references"
        create_file "#{skill_path}/references/.keep", ""
      end

      def show_instructions
        say "\nSkill '#{file_name}' created successfully!", :green
        say "\nLocation: #{skill_path}/", :blue
        say "\nNext steps:", :yellow
        say "  1. Edit #{skill_path}/SKILL.md to add your skill content"
        say "  2. Add reference files in #{skill_path}/references/ (optional)" if options[:with_references]
        say "  3. The skill will be auto-loaded by Claude\n"
      end

      private

      def skill_path
        ".claude/skills/#{file_name}"
      end

      def skill_description
        options[:description] || "Custom skill for #{file_name.titleize}"
      end

      def skill_tags
        case options[:template]
        when "model"
          %w[activerecord models database]
        when "controller"
          %w[controllers routing actions]
        when "frontend"
          %w[views frontend ui]
        else
          ["custom"]
        end
      end

      def template_sections
        case options[:template]
        when "model"
          model_template_sections
        when "controller"
          controller_template_sections
        when "frontend"
          frontend_template_sections
        else
          generic_template_sections
        end
      end

      def generic_template_sections
        <<~SECTIONS
          ## Quick Reference

          | Command | Purpose |
          |---------|---------|
          | TODO    | Add commands here |

          ## Overview

          #{skill_description}

          ## Usage

          Add usage examples and patterns here.

          ## Common Patterns

          Add frequently used code patterns here.

          ## Best Practices

          Add best practices and conventions here.
        SECTIONS
      end

      def model_template_sections
        <<~SECTIONS
          ## Quick Reference

          | Pattern | Example |
          |---------|---------|
          | Define Model | `class #{file_name.classify} < ApplicationRecord` |
          | Validation | `validates :field, presence: true` |
          | Association | `has_many :items` |

          ## Overview

          #{skill_description}

          ## Validations

          Add validation patterns here.

          ## Associations

          Add association patterns here.

          ## Scopes and Queries

          Add query patterns here.

          ## Callbacks

          Add callback patterns here.
        SECTIONS
      end

      def controller_template_sections
        <<~SECTIONS
          ## Quick Reference

          | Action | Purpose |
          |--------|---------|
          | index  | List resources |
          | show   | Display single resource |
          | new    | Form for creating |
          | create | Save new resource |
          | edit   | Form for editing |
          | update | Save changes |
          | destroy| Delete resource |

          ## Overview

          #{skill_description}

          ## Standard Actions

          Add standard CRUD action patterns here.

          ## Custom Actions

          Add custom action patterns here.

          ## Filters and Callbacks

          Add before_action and other filter patterns here.
        SECTIONS
      end

      def frontend_template_sections
        <<~SECTIONS
          ## Quick Reference

          | Pattern | Usage |
          |---------|-------|
          | Partial | `<%= render 'partial' %>` |
          | Helper  | `<%= helper_method %>` |
          | Link    | `<%= link_to 'Text', path %>` |

          ## Overview

          #{skill_description}

          ## Templates

          Add view template patterns here.

          ## Helpers

          Add helper method patterns here.

          ## Components

          Add component patterns here.
        SECTIONS
      end
    end
  end
end
