# frozen_string_literal: true

require "rails/generators"

module Claude
  module Generators
    class RuleGenerator < Rails::Generators::NamedBase
      source_root File.expand_path("templates", __dir__)

      class_option :paths, type: :string, default: nil,
                           desc: "Comma-separated paths where this rule applies (e.g., 'app/models/**/*,db/**/*')"
      class_option :template, type: :string, default: "generic",
                              desc: "Template type (generic, testing, security, performance)"

      def create_rule_file
        template "rule.md.tt", rule_path
      end

      def show_instructions
        say "\nRule '#{file_name}' created successfully!", :green
        say "\nLocation: #{rule_path}", :blue
        say "\nScope: #{rule_scope}", :yellow
        say "\nNext steps:", :yellow
        say "  1. Edit #{rule_path} to add your project rules"
        say "  2. The rule will be auto-loaded by Claude"
        say "  3. Claude will follow these rules when working in the specified paths\n"
      end

      private

      def rule_path
        ".claude/rules/#{file_name}.md"
      end

      def rule_scope
        options[:paths] || "All files"
      end

      def paths?
        options[:paths].present?
      end

      def rule_content
        case options[:template]
        when "testing"
          testing_template_content
        when "security"
          security_template_content
        when "performance"
          performance_template_content
        else
          generic_template_content
        end
      end

      def generic_template_content
        <<~CONTENT
          Add your project rules and guidelines here.

          ## Overview

          Describe the purpose of these rules and when they apply.

          ## Guidelines

          - Add specific guidelines
          - Include best practices
          - Document conventions
          - Provide examples

          ## Common Patterns

          Show examples of correct patterns to follow.

          ## Anti-Patterns

          Show examples of what to avoid.
        CONTENT
      end

      def testing_template_content
        <<~CONTENT
          Guidelines for writing and maintaining tests in this project.

          ## Test Structure

          - One test file per source file
          - Use descriptive test names
          - Group related tests together
          - Keep tests focused and independent

          ## Best Practices

          - Write tests before or alongside code
          - Use appropriate test types (unit, integration, system)
          - Mock external dependencies
          - Keep tests fast and reliable

          ## Coverage Requirements

          - Aim for high test coverage
          - Focus on critical paths
          - Test edge cases and error conditions
        CONTENT
      end

      def security_template_content
        <<~CONTENT
          Security guidelines and requirements for this project.

          ## Input Validation

          - Always validate and sanitize user input
          - Use strong parameters in controllers
          - Never trust external data

          ## Authentication & Authorization

          - Implement proper authentication
          - Enforce authorization for sensitive actions
          - Use secure session management

          ## Common Vulnerabilities

          Protect against:
          - SQL Injection
          - XSS (Cross-Site Scripting)
          - CSRF (Cross-Site Request Forgery)
          - Mass Assignment
          - Insecure Direct Object References

          ## Dependencies

          - Keep dependencies up to date
          - Run security audits regularly
          - Review security advisories
        CONTENT
      end

      def performance_template_content
        <<~CONTENT
          Performance optimization guidelines for this project.

          ## Database Queries

          - Avoid N+1 queries (use eager loading)
          - Add appropriate indexes
          - Limit data returned from queries
          - Use database-specific optimizations

          ## Caching

          - Cache expensive operations
          - Use fragment caching for views
          - Implement HTTP caching headers
          - Consider background jobs for slow tasks

          ## Asset Optimization

          - Minimize and compress assets
          - Use CDN for static assets
          - Implement lazy loading where appropriate
          - Optimize images and media files

          ## Monitoring

          - Track performance metrics
          - Monitor query performance
          - Set up alerts for slowdowns
          - Profile code regularly
        CONTENT
      end
    end
  end
end
