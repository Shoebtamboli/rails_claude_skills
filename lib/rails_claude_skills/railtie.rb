# frozen_string_literal: true

module RailsClaudeSkills
  class Railtie < Rails::Railtie
    railtie_name :rails_claude_skills

    generators do
      require "generators/claude/install/install_generator"
      require "generators/claude/skill/skill_generator"
      require "generators/claude/agent/agent_generator"
      require "generators/claude/command/command_generator"
      require "generators/claude/rule/rule_generator"
      require "generators/claude/views/views_generator"
    end
  end
end
