# Complex Permissions with CanCanCan

Advanced authorization patterns for sophisticated business logic and edge cases.

## Attribute-Level Permissions

Controlling which fields users can read or modify:

### Read-Only Fields

```ruby
# app/models/ability.rb
class Ability
  include CanCan::Ability

  def initialize(user)
    return unless user.present?

    # Users can update their posts
    can :update, Post, user_id: user.id

    # But cannot change published status
    cannot :update, Post, :published unless user.admin?

    # Cannot change featured status
    cannot :update, Post, :featured unless user.editor?
  end
end
```

### Controller Implementation

```ruby
# app/controllers/posts_controller.rb
class PostsController < ApplicationController
  def update
    @post = Post.find(params[:id])
    authorize! :update, @post

    # Check specific attributes
    if params[:post][:published] && cannot?(:update, @post, :published)
      params[:post].delete(:published)
      flash[:warning] = "You cannot change the published status"
    end

    if @post.update(post_params)
      redirect_to @post
    else
      render :edit
    end
  end

  private

  def post_params
    permitted = [:title, :body]
    permitted << :published if can?(:update, @post, :published)
    permitted << :featured if can?(:update, @post, :featured)

    params.require(:post).permit(*permitted)
  end
end
```

## Conditional Permissions Based on State

### Time-Based Editing Windows

```ruby
# app/models/ability.rb
class Ability
  include CanCan::Ability

  def initialize(user)
    return unless user.present?

    # Can edit posts within 1 hour of creation
    can :update, Post do |post|
      post.user_id == user.id && post.created_at > 1.hour.ago
    end

    # Can delete comments within 15 minutes
    can :destroy, Comment do |comment|
      comment.user_id == user.id && comment.created_at > 15.minutes.ago
    end

    # Admins bypass time restrictions
    if user.admin?
      can :manage, [Post, Comment]
    end
  end
end
```

### Workflow State Permissions

```ruby
# app/models/post.rb
class Post < ApplicationRecord
  include AASM

  aasm column: :status do
    state :draft, initial: true
    state :pending_review
    state :published
    state :archived

    event :submit do
      transitions from: :draft, to: :pending_review
    end

    event :publish do
      transitions from: :pending_review, to: :published
    end

    event :archive do
      transitions from: :published, to: :archived
    end
  end
end

# app/models/ability.rb
class Ability
  include CanCan::Ability

  def initialize(user)
    return unless user.present?

    # Authors can edit their own drafts
    can :update, Post, user_id: user.id, status: 'draft'

    # Can submit for review
    can :submit, Post, user_id: user.id, status: 'draft'

    # Editors can review and publish
    if user.editor? || user.admin?
      can :publish, Post, status: 'pending_review'
      can :update, Post, status: 'pending_review'
    end

    # Only admins can archive
    if user.admin?
      can :archive, Post, status: 'published'
      can :manage, Post, status: 'archived'
    end

    # Nobody can edit published posts (except admins)
    cannot :update, Post, status: 'published' unless user.admin?
  end
end
```

## Hierarchical Permissions

### Role Hierarchy

```ruby
# app/models/user.rb
class User < ApplicationRecord
  enum role: {
    viewer: 0,
    contributor: 1,
    editor: 2,
    manager: 3,
    admin: 4
  }

  def role_level
    User.roles[role]
  end

  def has_role?(check_role)
    role_level >= User.roles[check_role.to_s]
  end
end

# app/models/ability.rb
class Ability
  include CanCan::Ability

  def initialize(user)
    return unless user.present?

    # Everyone can read published content
    can :read, Post, published: true

    # Viewers (level 0) - read only
    can :read, Post if user.has_role?(:viewer)

    # Contributors (level 1) - can create and edit own
    if user.has_role?(:contributor)
      can :create, Post
      can [:update, :destroy], Post, user_id: user.id
    end

    # Editors (level 2) - can manage others' content
    if user.has_role?(:editor)
      can :manage, Post
      can :publish, Post
    end

    # Managers (level 3) - can manage users
    if user.has_role?(:manager)
      can :manage, [Post, Comment, Category]
      can :read, User
      can :update, User do |target_user|
        target_user.role_level < user.role_level
      end
    end

    # Admins (level 4) - full access
    can :manage, :all if user.has_role?(:admin)
  end
end
```

## Group and Team Permissions

```ruby
# app/models/team.rb
class Team < ApplicationRecord
  has_many :team_memberships
  has_many :users, through: :team_memberships
  has_many :projects
end

# app/models/team_membership.rb
class TeamMembership < ApplicationRecord
  belongs_to :user
  belongs_to :team

  enum role: { member: 0, lead: 1, owner: 2 }
end

# app/models/ability.rb
class Ability
  include CanCan::Ability

  def initialize(user)
    return unless user.present?

    # Get all teams user belongs to
    team_ids = user.teams.pluck(:id)

    # Can read team projects
    can :read, Project, team_id: team_ids

    # Can contribute to team projects
    can :create, Task, project: { team_id: team_ids }
    can :update, Task, project: { team_id: team_ids }, user_id: user.id

    # Team leads can manage project tasks
    lead_team_ids = user.team_memberships.where(role: [:lead, :owner]).pluck(:team_id)
    can :manage, Task, project: { team_id: lead_team_ids }

    # Team owners can manage teams
    owned_team_ids = user.team_memberships.where(role: :owner).pluck(:team_id)
    can :manage, Team, id: owned_team_ids
    can :manage, TeamMembership, team_id: owned_team_ids
  end
end
```

## Delegated Permissions

### Sharing and Collaboration

```ruby
# app/models/document.rb
class Document < ApplicationRecord
  belongs_to :owner, class_name: 'User'
  has_many :document_shares
  has_many :shared_with_users, through: :document_shares, source: :user
end

# app/models/document_share.rb
class DocumentShare < ApplicationRecord
  belongs_to :document
  belongs_to :user

  enum permission: { read: 0, write: 1, admin: 2 }
end

# app/models/ability.rb
class Ability
  include CanCan::Ability

  def initialize(user)
    return unless user.present?

    # Owner has full control
    can :manage, Document, owner_id: user.id

    # Shared documents - read permission
    can :read, Document, document_shares: { user_id: user.id, permission: [:read, :write, :admin] }

    # Shared documents - write permission
    can :update, Document, document_shares: { user_id: user.id, permission: [:write, :admin] }

    # Shared documents - admin permission (can share with others)
    can :share, Document, document_shares: { user_id: user.id, permission: :admin }
  end
end

# app/controllers/documents_controller.rb
class DocumentsController < ApplicationController
  def share
    @document = Document.find(params[:id])
    authorize! :share, @document

    @share = @document.document_shares.create(
      user_id: params[:user_id],
      permission: params[:permission]
    )

    redirect_to @document, notice: 'Document shared successfully'
  end
end
```

## Conditional Abilities Based on External Services

```ruby
# app/models/ability.rb
class Ability
  include CanCan::Ability

  def initialize(user, context = {})
    return unless user.present?

    # Check subscription status from external service
    if context[:subscription_service]
      subscription = context[:subscription_service].get_subscription(user.id)

      case subscription.plan
      when 'free'
        can :create, Post
        cannot :create, Post if user.posts.count >= 5  # Free tier limit
      when 'pro'
        can :create, Post
        can :upload, :attachments
      when 'enterprise'
        can :manage, :all
        can :access, :analytics
      end
    end

    # Feature flags
    if context[:feature_flags]
      can :access, :beta_features if context[:feature_flags].enabled?(:beta_features, user)
      can :use, :ai_assistant if context[:feature_flags].enabled?(:ai_assistant, user)
    end
  end
end

# app/controllers/application_controller.rb
def current_ability
  @current_ability ||= Ability.new(current_user, {
    subscription_service: SubscriptionService.new,
    feature_flags: FeatureFlags.new
  })
end
```

## IP-Based Restrictions

```ruby
# app/models/ability.rb
class Ability
  include CanCan::Ability

  def initialize(user, request = nil)
    return unless user.present?

    can :read, Post

    # Admin access only from specific IPs
    if user.admin?
      if request && allowed_admin_ip?(request.remote_ip)
        can :manage, :all
      else
        can :read, :all
        cannot :destroy, :all
      end
    end
  end

  private

  def allowed_admin_ip?(ip)
    allowed_ranges = [
      IPAddr.new('10.0.0.0/8'),
      IPAddr.new('172.16.0.0/12'),
      IPAddr.new('192.168.0.0/16')
    ]

    allowed_ranges.any? { |range| range.include?(ip) }
  end
end

# app/controllers/application_controller.rb
def current_ability
  @current_ability ||= Ability.new(current_user, request)
end
```

## Performance Optimization for Complex Rules

### Caching Abilities

```ruby
# app/models/ability.rb
class Ability
  include CanCan::Ability

  def initialize(user)
    return unless user.present?

    # Cache expensive queries
    @user_team_ids = user.teams.pluck(:id)
    @user_organization_id = user.organization_id

    define_permissions
  end

  private

  def define_permissions
    can :read, Project, team_id: @user_team_ids
    can :read, Project, organization_id: @user_organization_id
  end
end
```

### Eager Loading for Better Performance

```ruby
# app/controllers/posts_controller.rb
class PostsController < ApplicationController
  def index
    @posts = Post
      .includes(:user, :category)
      .accessible_by(current_ability)
      .page(params[:page])
  end
end
```

### Using Database Views for Complex Permissions

```ruby
# db/migrate/20240101000000_create_accessible_posts_view.rb
class CreateAccessiblePostsView < ActiveRecord::Migration[7.0]
  def up
    execute <<-SQL
      CREATE VIEW accessible_posts AS
      SELECT p.*,
             u.organization_id,
             CASE
               WHEN p.published = true THEN true
               WHEN p.user_id = u.id THEN true
               WHEN EXISTS (
                 SELECT 1 FROM team_memberships tm
                 JOIN teams t ON tm.team_id = t.id
                 WHERE tm.user_id = u.id AND t.id = p.team_id
               ) THEN true
               ELSE false
             END as user_can_access
      FROM posts p
      CROSS JOIN users u
    SQL
  end

  def down
    execute "DROP VIEW accessible_posts"
  end
end
```

## Testing Complex Permissions

```ruby
# spec/models/ability_spec.rb
require 'rails_helper'
require 'cancan/matchers'

RSpec.describe Ability, type: :model do
  describe 'complex workflow permissions' do
    let(:author) { create(:user, role: :contributor) }
    let(:editor) { create(:user, role: :editor) }
    let(:admin) { create(:user, role: :admin) }

    let(:draft_post) { create(:post, user: author, status: :draft) }
    let(:pending_post) { create(:post, user: author, status: :pending_review) }
    let(:published_post) { create(:post, user: author, status: :published) }

    describe 'author abilities' do
      subject(:ability) { Ability.new(author) }

      it { is_expected.to be_able_to(:update, draft_post) }
      it { is_expected.to be_able_to(:submit, draft_post) }
      it { is_expected.not_to be_able_to(:update, pending_post) }
      it { is_expected.not_to be_able_to(:update, published_post) }
      it { is_expected.not_to be_able_to(:publish, pending_post) }
    end

    describe 'editor abilities' do
      subject(:ability) { Ability.new(editor) }

      it { is_expected.to be_able_to(:update, pending_post) }
      it { is_expected.to be_able_to(:publish, pending_post) }
      it { is_expected.not_to be_able_to(:update, published_post) }
    end

    describe 'admin abilities' do
      subject(:ability) { Ability.new(admin) }

      it { is_expected.to be_able_to(:update, draft_post) }
      it { is_expected.to be_able_to(:update, pending_post) }
      it { is_expected.to be_able_to(:update, published_post) }
      it { is_expected.to be_able_to(:archive, published_post) }
    end
  end

  describe 'time-based permissions' do
    let(:user) { create(:user) }
    let(:recent_post) { create(:post, user: user, created_at: 30.minutes.ago) }
    let(:old_post) { create(:post, user: user, created_at: 2.hours.ago) }

    subject(:ability) { Ability.new(user) }

    it { is_expected.to be_able_to(:update, recent_post) }
    it { is_expected.not_to be_able_to(:update, old_post) }
  end

  describe 'delegated permissions' do
    let(:owner) { create(:user) }
    let(:viewer) { create(:user) }
    let(:editor) { create(:user) }
    let(:document) { create(:document, owner: owner) }

    before do
      create(:document_share, document: document, user: viewer, permission: :read)
      create(:document_share, document: document, user: editor, permission: :write)
    end

    it 'grants correct permissions to shared users' do
      viewer_ability = Ability.new(viewer)
      editor_ability = Ability.new(editor)

      expect(viewer_ability).to be_able_to(:read, document)
      expect(viewer_ability).not_to be_able_to(:update, document)

      expect(editor_ability).to be_able_to(:read, document)
      expect(editor_ability).to be_able_to(:update, document)
    end
  end
end
```

## Best Practices

1. **Keep it readable**: Complex logic should be well-commented
2. **Use methods**: Extract complex conditions into well-named methods
3. **Cache expensive queries**: Store team IDs, organization IDs in variables
4. **Test thoroughly**: Cover all edge cases and state transitions
5. **Document business rules**: Explain why permissions exist
6. **Avoid over-engineering**: Start simple, add complexity only when needed
7. **Monitor performance**: Use database indexes and eager loading
8. **Separate concerns**: Use different ability classes for different contexts if needed
9. **Version control**: Track permission changes in version control
10. **Audit access**: Log permission checks for sensitive operations
