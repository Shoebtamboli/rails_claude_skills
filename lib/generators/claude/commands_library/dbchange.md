---
description: Generate a database migration with safety checks
argument-hint: [migration_description]
allowed-tools: Bash, Read, Edit
---

Generate a migration: $ARGUMENTS

Safety checklist:
1. ✅ Use reversible migrations when possible
2. ✅ Add indexes for foreign keys
3. ✅ Use `change` method instead of up/down when possible
4. ✅ Consider data migration needs
5. ✅ Add comments for complex changes

After generation:
- Review the migration file
- Check for potential downtime issues
- Suggest background migration if needed for large tables
