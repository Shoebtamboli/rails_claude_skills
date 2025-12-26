# frozen_string_literal: true

require_relative "rails_claude_skills/version"
require_relative "rails_claude_skills/railtie" if defined?(Rails::Railtie)

module RailsClaudeSkills
  class Error < StandardError; end

  class << self
    attr_accessor :configuration
  end

  def self.configure
    self.configuration ||= Configuration.new
    yield(configuration)
  end

  class Configuration
    attr_accessor :skills_path, :agents_path, :default_model

    def initialize
      @skills_path = ".claude/skills"
      @agents_path = ".claude/agents"
      @default_model = "sonnet"
    end
  end
end
