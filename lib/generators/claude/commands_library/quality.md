---
description: Run RuboCop, Brakeman, and security audits
allowed-tools: Bash
---

## Current Code Quality

**RuboCop (Style):**
!`bundle exec rubocop`

**Brakeman (Security):**
!`bundle exec brakeman -q`

**Bundler Audit (Gem Vulnerabilities):**
!`bundle exec bundler-audit check --update`

Analyze the results above and:
1. Summarize any violations or vulnerabilities
2. Suggest fixes for critical issues
3. Offer to auto-fix RuboCop issues if needed
