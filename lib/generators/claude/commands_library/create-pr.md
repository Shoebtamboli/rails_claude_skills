---
description: Create a branch, commit changes, and open a pull request
argument-hint: [branch_name] [commit_message] [pr_title]
allowed-tools: Bash
---

Create a pull request workflow for: $ARGUMENTS

Steps:
1. ✅ Check for uncommitted changes
2. ✅ Create and checkout new branch
3. ✅ Stage all changes
4. ✅ Create commit with descriptive message
5. ✅ Push to remote
6. ✅ Create pull request using gh CLI
7. ✅ Display PR URL

Commit message format:
```
{commit_message}

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>
```

Note: Requires GitHub CLI (`gh`) to be installed and authenticated.
