# frozen_string_literal: true

RSpec.describe RailsClaudeSkills do
  it "has a version number" do
    expect(RailsClaudeSkills::VERSION).not_to be nil
  end

  it "has a Configuration class" do
    expect(RailsClaudeSkills::Configuration).to be_a(Class)
  end

  describe "Configuration" do
    it "has default values" do
      config = RailsClaudeSkills::Configuration.new
      expect(config.skills_path).to eq(".claude/skills")
      expect(config.agents_path).to eq(".claude/agents")
      expect(config.default_model).to eq("sonnet")
      expect(config.auto_load_skills).to be true
    end
  end

  describe ".configure" do
    it "allows configuration via block" do
      RailsClaudeSkills.configure do |config|
        config.skills_path = "custom/skills"
        config.default_model = "opus"
      end

      expect(RailsClaudeSkills.configuration.skills_path).to eq("custom/skills")
      expect(RailsClaudeSkills.configuration.default_model).to eq("opus")
    end
  end
end
