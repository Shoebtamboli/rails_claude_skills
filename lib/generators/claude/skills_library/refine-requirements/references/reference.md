# Requirement Refinement Question Templates

This reference provides targeted question templates for different feature types in Rails applications. Use these as a guide when refining requirements.

## Authentication & Authorization Features

### User Registration/Login

**Data & Security:**
- What fields are required for registration? (email only, or email + username + phone?)
- Password requirements? (minimum length, complexity, expiration?)
- Email verification required before account activation?
- Social auth providers? (Google, GitHub, Facebook?)
- Should we use Devise or custom implementation?

**Session Management:**
- Session duration? (default, remember me option?)
- Single session per user or allow multiple devices?
- What happens to active sessions when password is reset?
- Rate limiting for login attempts?

**Password Recovery:**
- Password reset via email only or also SMS/phone?
- Reset token expiration time?
- Require old password for password changes?
- Password history tracking (prevent reuse)?

**User Roles:**
- What roles exist? (admin, moderator, user?)
- Role assignment: manual by admin or automatic based on criteria?
- Can users have multiple roles?
- Role-based UI differences?

### Multi-Factor Authentication (MFA)

- MFA required for all users or optional?
- MFA methods: TOTP (app-based), SMS, email, backup codes?
- When is MFA prompted? (every login, new device, sensitive actions?)
- Backup recovery method if MFA device lost?
- Admin override capability for MFA?

## CRUD Features (Posts, Comments, Products, etc.)

### Data Model

**Core Fields:**
- Required vs optional fields?
- Field types and validations? (length limits, format requirements)
- Default values for any fields?
- Computed/derived fields needed?

**Associations:**
- Belongs to User? Which user field (author, creator, owner)?
- Polymorphic associations needed? (commentable, likeable)
- Has many children? (nested comments, variants)
- Join tables for many-to-many relationships?

**Lifecycle:**
- Draft vs published states?
- Soft delete or hard delete?
- Archive/deactivate functionality?
- Versioning or edit history needed?

### Permissions & Access Control

- Who can create? (all users, specific roles, anyone including guests?)
- Who can view? (public, owner only, role-based?)
- Who can edit? (owner only, admins, time-limited?)
- Who can delete? (owner only, admins, never?)
- Transfer ownership allowed?

### UI & User Experience

**Creation/Editing:**
- Inline editing or separate edit page?
- Auto-save drafts?
- Preview before publishing?
- Rich text editor or plain text?
- File/image uploads allowed? (size limits, file types)

**Listing/Browsing:**
- Default sort order? (newest first, popularity, alphabetical)
- Pagination or infinite scroll?
- Filters available? (by status, author, date range, tags)
- Search functionality? (simple text or advanced with filters)
- Bulk actions? (bulk delete, bulk status change)

**Real-time Updates:**
- Live updates when data changes? (Turbo Streams, WebSockets)
- Optimistic UI updates?
- Conflict resolution for concurrent edits?

### Validations & Business Rules

- Unique constraints? (title uniqueness, email uniqueness)
- Cross-field validations? (end date after start date)
- Custom validation rules?
- What happens when validation fails? (inline errors, flash messages)

## Dashboard & Admin Features

### Data Display

**Metrics:**
- Which metrics to display? (counts, sums, averages, trends)
- Time ranges? (today, week, month, year, custom)
- Comparison to previous period?
- Real-time or cached data?

**Visualizations:**
- Chart types needed? (line, bar, pie, table)
- Interactive charts or static?
- Export charts as images?

### Filtering & Search

- Available filters? (date range, status, user, category)
- Filter persistence (save in session, URL params)?
- Saved filter presets?
- Advanced search with multiple criteria?

### Data Export

- Export formats? (CSV, Excel, PDF, JSON)
- Full dataset or filtered results?
- Background job for large exports?
- Email export file or download immediately?

### Access Control

- Who can access dashboard? (admins only, specific roles)
- Row-level permissions? (see only own data vs all data)
- Action permissions? (view only, can export, can modify settings)

## API Endpoints

### Authentication & Authorization

- API authentication method? (JWT, API keys, session-based)
- Token expiration and refresh?
- Rate limiting per user/IP?
- API versioning strategy? (/v1/, accept header, subdomain)

### Request/Response Format

- JSON only or also support XML?
- Pagination style? (offset/limit, cursor-based, page numbers)
- Include metadata? (total count, next/prev links)
- Field filtering? (sparse fieldsets, select specific fields)
- Include nested associations? (include=comments, sideloading)

### Error Handling

- Error response format? (RFC 7807, custom format)
- Validation error details?
- HTTP status codes strategy?
- Error codes for client handling?

### Documentation

- API documentation needed? (OpenAPI/Swagger, manual)
- Interactive API explorer?
- Code examples in multiple languages?

## Background Jobs & Scheduled Tasks

### Triggering

- What triggers the job? (user action, schedule, event)
- Immediate or delayed execution?
- Scheduled frequency? (hourly, daily, cron expression)
- Job arguments and configuration?

### Execution

- Idempotent (safe to retry)?
- Job timeout duration?
- Retry strategy? (how many times, backoff)
- Job priority levels?

### Monitoring & Error Handling

- How to monitor job status?
- Notifications on failure? (email, Slack, logging)
- Dead letter queue for failed jobs?
- Dashboard for job history?

## Email & Notifications

### Delivery

- Email service? (ActionMailer with SMTP, SendGrid, Postmark, SES)
- Async delivery? (background job via Solid Queue)
- Email templates: HTML, text, or both?
- Preview functionality for developers?

### Content & Timing

- What triggers the email? (user action, scheduled, event)
- Immediate or batched delivery?
- User preferences for email frequency?
- Unsubscribe mechanism?

### Notification Types

- In-app notifications? (in addition to email)
- Push notifications? (web push, mobile)
- SMS notifications?
- Notification grouping/batching?

## File Uploads & Storage

### Upload Constraints

- Allowed file types? (images only, PDFs, any file)
- File size limits?
- Number of files per upload?
- Direct upload to cloud or via server?

### Storage & Processing

- Storage backend? (Active Storage with S3, local, GCS)
- Image processing? (variants, thumbnails, resizing)
- Virus scanning?
- CDN for serving files?

### Access Control

- Public files or authenticated access?
- Signed URLs with expiration?
- Download limits or tracking?
- Bulk download as zip?

## Search & Filtering

### Search Scope

- What can be searched? (titles, bodies, tags, users)
- Full-text search needed? (pg_search, Elasticsearch)
- Fuzzy matching or exact?
- Search across multiple models?

### Performance

- Search response time requirements?
- Indexing strategy? (database, external search engine)
- Caching search results?
- Typeahead/autocomplete needed?

## Common Cross-Cutting Concerns

### Performance

- Expected traffic/load? (requests per second, concurrent users)
- Response time requirements? (< 100ms, < 500ms)
- Caching strategy? (fragment caching, Russian doll, HTTP)
- Database query optimization needed?

### Security

- CSRF protection (default Rails behavior ok?)
- XSS prevention (auto-escaping ok or need sanitization?)
- SQL injection prevention (using ActiveRecord only?)
- Sensitive data encryption at rest?
- Audit logging for admin actions?

### Mobile & Responsive

- Mobile-specific behavior different from desktop?
- Touch-optimized interactions needed?
- Offline support required?
- Progressive Web App (PWA) features?

### Internationalization (i18n)

- Multi-language support needed now or later?
- Which languages?
- User language preference storage?
- RTL language support?

### Accessibility

- WCAG level required? (A, AA, AAA)
- Screen reader optimization priority?
- Keyboard navigation requirements?
- Color contrast requirements?

## Usage Tips

1. **Prioritize questions** based on implementation impact
2. **Ask 3-5 questions max** per refinement session
3. **Provide context** for why each question matters
4. **Offer options** when asking multiple-choice questions
5. **Follow up** on ambiguous answers
6. **Document answers** in task acceptance criteria
7. **Update technical approach** based on answers

This reference ensures comprehensive requirement gathering while avoiding analysis paralysis.
