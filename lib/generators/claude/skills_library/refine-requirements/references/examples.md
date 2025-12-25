# Requirement Refinement Examples

Real-world examples of requirement refinement sessions showing how follow-up questions lead to better implementation plans.

## Example 1: Blog Post Commenting System

### Initial Plan (from /plan-feature)

**Feature:** Add commenting system for blog posts

**Initial Tasks:**
1. Create Comment model with migration
2. Add CommentsController with CRUD actions
3. Build comment form partial
4. Display comments list
5. Add tests

### Refinement Session

**Questions Asked:**

**Q1: Comment Threading**
- Header: "Nesting"
- Question: "Should comments support nested replies (threaded discussions) or stay flat?"
- Options:
  - Flat comments only (simpler)
  - One level of nesting (reply to comments)
  - Unlimited nesting depth (full threading)

**Answer:** One level of nesting

**Q2: Moderation**
- Header: "Moderation"
- Question: "How should comment moderation work?"
- Options:
  - Auto-publish all comments
  - Admin approval required before publishing
  - Auto-publish but allow flagging for review
  - Spam detection with Akismet integration

**Answer:** Auto-publish but allow flagging for review

**Q3: Editing & Deletion**
- Header: "Edit/Delete"
- Question: "Can users edit or delete their comments after posting?"
- Options:
  - No editing or deletion
  - Edit within 5 minutes of posting
  - Edit anytime, show edit indicator
  - Soft delete only (hide but preserve)

**Answer:** Edit within 5 minutes, soft delete

**Q4: Notifications**
- Header: "Notifications"
- Question: "Should users be notified of replies to their comments?"
- Options:
  - No notifications
  - Email notifications (immediate)
  - In-app notifications only
  - Both email and in-app with user preference

**Answer:** Both email and in-app with user preference

### Updated Implementation Plan

**New/Modified Tasks:**

1. ✏️ **Updated:** Create Comment model with migration
   - Add `parent_id` for one-level nesting
   - Add `deleted_at` for soft deletes
   - Add `edited` boolean flag
   - Add `flagged` boolean and `flag_count` integer
   - Add indexes: `parent_id`, `deleted_at`, `post_id + created_at`

2. **New:** Add CommentNotificationPreference model
   - Migration for user notification preferences
   - Default to email + in-app enabled

3. ✏️ **Updated:** Add CommentsController
   - CRUD actions
   - Add `flag` action for reporting
   - Add edit action with 5-minute time check
   - Add soft delete (update deleted_at)
   - Add `replies` action for nested comments

4. **New:** Add CommentNotificationJob
   - Background job to send email notifications
   - Check user preferences before sending
   - Use ActionMailer

5. ✏️ **Updated:** Build comment form partial
   - Support reply context (parent comment)
   - Show "replying to @username"
   - Cancel reply button

6. ✏️ **Updated:** Display comments list
   - Show nested replies (indented)
   - Show edit indicator if edited
   - Hide deleted comments (show "[deleted]")
   - Flag button for inappropriate content
   - Edit button (only if < 5 minutes and owner)
   - Delete button (owner only)

7. **New:** Add in-app notification system
   - Create Notification model
   - Add notification bell UI component
   - Mark as read functionality

8. **New:** Add admin moderation dashboard
   - List flagged comments
   - Approve/delete actions
   - Ban user capability

9. ✏️ **Updated:** Add tests
   - Test nested replies
   - Test soft delete behavior
   - Test edit time window
   - Test flagging workflow
   - Test notification delivery

**Scope Change:**
- Original: 5 tasks
- Refined: 13 tasks
- Effort: Significantly increased (but prevented rework)

---

## Example 2: User Authentication

### Initial Plan

**Feature:** Add user login with email/password

**Initial Tasks:**
1. Install Devise
2. Generate User model
3. Add login/logout routes
4. Create login form
5. Add tests

### Refinement Session

**Questions Asked:**

**Q1: Registration Flow**
"What's required for user registration?"
- Email + password only
- Email + password + name ✓
- Email + password + name + profile photo
- OAuth only (Google/GitHub)

**Q2: Email Verification**
"Should users verify email before accessing the app?"
- No verification needed
- Optional verification (can use app immediately) ✓
- Required verification (can't login until verified)

**Q3: Password Security**
"What password security requirements?"
- Basic (6+ characters)
- Medium (8+ chars, mix of letters/numbers) ✓
- Strong (10+ chars, uppercase, lowercase, numbers, symbols)

**Q4: Session Management**
"How should user sessions work?"
- Standard session (logout on browser close)
- Remember me checkbox (30 days) ✓
- Always remember (persistent session)

### Updated Implementation Plan

**Changes:**
- Added name field to User model
- Added email confirmation columns
- Added Devise confirmable module
- Added password strength validator gem
- Added remember_me checkbox to login form
- Added welcome email on registration
- Added email confirmation instructions email
- Added profile name to navigation
- Added tests for email confirmation flow
- Added tests for password validation
- Added tests for remember me functionality

**Scope Change:**
- Original: 5 tasks
- Refined: 9 tasks

---

## Example 3: Admin Dashboard

### Initial Plan

**Feature:** Create admin dashboard to manage posts

**Initial Tasks:**
1. Add admin role to User model
2. Create Admin::PostsController
3. Build admin posts index view
4. Add authorization checks
5. Add tests

### Refinement Session

**Questions Asked:**

**Q1: Metrics Display**
"What metrics should the dashboard show?"
- Just post count
- Post count + user count + comment count ✓
- Full analytics (views, engagement, trends)

**Q2: Filtering**
"How should admins filter posts?"
- No filtering
- By status (published/draft) ✓
- By status + author + date range ✓

**Q3: Bulk Actions**
"Should admins be able to perform bulk actions?"
- No bulk actions
- Bulk delete only
- Bulk publish/unpublish ✓
- Full bulk edit capabilities

**Q4: Activity Log**
"Should admin actions be logged?"
- No logging
- Log in Rails logger only
- Database audit log ✓
- Database log + email notifications for critical actions

### Updated Implementation Plan

**Changes:**
- Added dashboard homepage with metrics cards
- Added counter caches for metrics
- Added filtering form with status, author, date range
- Added bulk action checkboxes
- Added bulk controller actions
- Added AdminAuditLog model
- Added audit log viewer
- Added Turbo Frames for inline editing
- Added Stimulus controller for bulk selection
- Extended test coverage for all features

**Scope Change:**
- Original: 5 tasks
- Refined: 14 tasks

---

## Example 4: API Endpoint

### Initial Plan

**Feature:** Add JSON API for blog posts

**Initial Tasks:**
1. Create API::PostsController
2. Add JSON serialization
3. Add API routes
4. Add tests

### Refinement Session

**Questions Asked:**

**Q1: Authentication**
"How should API clients authenticate?"
- No authentication (public API)
- API keys ✓
- JWT tokens
- OAuth 2.0

**Q2: Versioning**
"How should we version the API?"
- No versioning
- URL versioning (/api/v1) ✓
- Header versioning
- Query parameter versioning

**Q3: Rate Limiting**
"Should we rate limit API requests?"
- No rate limiting
- Basic rate limit (100 requests/hour per IP)
- Tiered rate limits by API key tier ✓
- Dynamic rate limiting based on load

**Q4: Response Format**
"What should API responses include?"
- Just the data
- Data + metadata (pagination, links) ✓
- Data + metadata + HATEOAS links

### Updated Implementation Plan

**Changes:**
- Added ApiKey model with generation and tiers
- Added API authentication middleware
- Added rack-attack for rate limiting
- Added tier-based rate limit configuration
- Added /api/v1 namespace
- Added pagination with Kaminari
- Added metadata in responses
- Added API documentation with OpenAPI spec
- Added rate limit headers in responses
- Added API key management UI for admins
- Added comprehensive API tests

**Scope Change:**
- Original: 4 tasks
- Refined: 11 tasks

---

## Key Takeaways from Examples

### Common Patterns

1. **Initial plans are often too simple** - Missing edge cases, validation rules, and UX details
2. **Security and performance are often overlooked** - Rate limiting, authorization, caching
3. **User experience details matter** - Notifications, feedback, error handling
4. **Admin/management tools needed** - Moderation, audit logs, bulk actions

### Impact of Refinement

- **Prevents rework** - Catches requirements early
- **Improves quality** - Forces thinking about edge cases
- **Sets expectations** - User knows full scope upfront
- **Better estimates** - More accurate task breakdown

### Best Questions to Ask

1. **Edge cases** - What happens when X fails or is unusual?
2. **Permissions** - Who can do what?
3. **User experience** - How should this feel to use?
4. **Performance** - How fast must this be?
5. **Security** - What could go wrong?
6. **Scale** - How many records/users/requests?

Use these examples as templates for your own requirement refinement sessions.
