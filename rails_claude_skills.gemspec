# frozen_string_literal: true

require_relative "lib/rails_claude_skills/version"

Gem::Specification.new do |spec|
  spec.name = "rails_claude_skills"
  spec.version = RailsClaudeSkills::VERSION
  spec.authors = ["Shoeb"]
  spec.email = ["shoebtamboli98@gmail.com"]

  spec.summary = "Rails generators for Claude AI skills and agents"
  spec.description = "Scaffold reusable Claude AI skills and agents for Rails projects using familiar Rails generator patterns"
  spec.homepage = "https://github.com/shoebtamboli/rails_claude_skills"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ Gemfile .gitignore .rspec spec/])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Runtime dependencies
  spec.add_dependency "rails", ">= 7.0"

  # Development dependencies
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rubocop", "~> 1.60"
  spec.add_development_dependency "rubocop-rake", "~> 0.6"
  spec.add_development_dependency "rubocop-rspec", "~> 2.25"
end
