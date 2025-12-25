---
description: Generate a new Stimulus controller with proper setup
argument-hint: [controller_name]
allowed-tools: Bash, Write, Edit, Read
---

Generate a Stimulus controller: $ARGUMENTS

Steps:
1. Generate the controller: `rails g stimulus $ARGUMENTS`
2. Add example actions and targets
3. Show usage example in HTML
4. Follow Stimulus naming conventions

Best practices:
- Use data-controller for registration
- Use data-action for event bindings
- Use data-*-target for element references
- Keep controllers focused and single-purpose
