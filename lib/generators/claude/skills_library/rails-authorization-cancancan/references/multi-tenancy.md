# Multi-Tenancy Authorization with CanCanCan

Managing permissions in multi-tenant applications where users belong to organizations, accounts, or workspaces.

## Basic Multi-Tenant Setup

### Organization Model

```ruby
# app/models/organization.rb
class Organization < ApplicationRecord
  has_many :users
  has_many :posts
  has_many :projects
end

# app/models/user.rb
class User < ApplicationRecord
  belongs_to :organization

  enum role: { member: 0, manager: 1, admin: 2 }
end

# app/models/post.rb
class Post < ApplicationRecord
  belongs_to :organization
  belongs_to :user
end
```

### Ability Class for Multi-Tenancy

```ruby
# app/models/ability.rb
class Ability
  include CanCan::Ability

  def initialize(user)
    return unless user.present?

    # Scope all resources to user's organization
    can :read, Post, organization_id: user.organization_id
    can :create, Post, organization_id: user.organization_id
    can :update, Post, organization_id: user.organization_id, user_id: user.id
    can :destroy, Post, organization_id: user.organization_id, user_id: user.id

    # Managers can manage all posts in their organization
    if user.manager? || user.admin?
      can :manage, Post, organization_id: user.organization_id
    end

    # Only admins can manage organization settings
    if user.admin?
      can :manage, Organization, id: user.organization_id
      can :manage, User, organization_id: user.organization_id
    end
  end
end
```

## Controller Setup

### Setting Organization Context

```ruby
# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  before_action :set_organization

  private

  def set_organization
    @current_organization = current_user.organization
  end

  def current_organization
    @current_organization
  end
  helper_method :current_organization
end
```

### Scoping Resources

```ruby
# app/controllers/posts_controller.rb
class PostsController < ApplicationController
  load_and_authorize_resource

  def index
    # @posts automatically scoped to organization via accessible_by
    @posts = @posts.where(organization_id: current_organization.id)
  end

  def create
    @post.organization = current_organization
    if @post.save
      redirect_to @post
    else
      render :new
    end
  end

  private

  def post_params
    params.require(:post).permit(:title, :body)
  end
end
```

## Account-Based Multi-Tenancy

For apps where users can belong to multiple accounts/workspaces:

### Models

```ruby
# app/models/user.rb
class User < ApplicationRecord
  has_many :memberships
  has_many :accounts, through: :memberships

  def current_account=(account)
    @current_account = account
  end

  def current_account
    @current_account
  end
end

# app/models/membership.rb
class Membership < ApplicationRecord
  belongs_to :user
  belongs_to :account

  enum role: { member: 0, admin: 1, owner: 2 }
end

# app/models/account.rb
class Account < ApplicationRecord
  has_many :memberships
  has_many :users, through: :memberships
  has_many :projects
end
```

### Ability with Current Account

```ruby
# app/models/ability.rb
class Ability
  include CanCan::Ability

  def initialize(user, current_account = nil)
    return unless user.present?
    return unless current_account.present?

    # Find user's membership in current account
    membership = user.memberships.find_by(account: current_account)
    return unless membership

    # Base permissions for all members
    can :read, Project, account_id: current_account.id

    # Members can create projects
    if membership.member? || membership.admin? || membership.owner?
      can :create, Project, account_id: current_account.id
      can :update, Project, account_id: current_account.id, user_id: user.id
    end

    # Admins and owners can manage all projects
    if membership.admin? || membership.owner?
      can :manage, Project, account_id: current_account.id
    end

    # Only owners can manage account settings
    if membership.owner?
      can :manage, Account, id: current_account.id
      can :manage, Membership, account_id: current_account.id
    end
  end
end
```

### Controller with Account Context

```ruby
# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  before_action :set_current_account

  private

  def set_current_account
    if params[:account_id]
      @current_account = current_user.accounts.find(params[:account_id])
      current_user.current_account = @current_account
    elsif session[:current_account_id]
      @current_account = current_user.accounts.find_by(id: session[:current_account_id])
    else
      @current_account = current_user.accounts.first
    end

    session[:current_account_id] = @current_account&.id
  end

  def current_account
    @current_account
  end
  helper_method :current_account

  def current_ability
    @current_ability ||= Ability.new(current_user, current_account)
  end
end
```

### Account Switcher in Views

```ruby
# app/views/layouts/_account_switcher.html.erb
<div class="account-switcher">
  <% current_user.accounts.each do |account| %>
    <%= link_to account.name,
                account_path(account),
                class: (account == current_account ? 'active' : '') %>
  <% end %>
</div>
```

## Row-Level Security Pattern

For more complex authorization with nested resources:

```ruby
class Ability
  include CanCan::Ability

  def initialize(user, current_account = nil)
    return unless user.present?
    return unless current_account.present?

    # Projects
    can :manage, Project, account_id: current_account.id

    # Tasks belong to projects, which belong to accounts
    can :read, Task, project: { account_id: current_account.id }
    can :create, Task, project: { account_id: current_account.id }
    can :update, Task, project: { account_id: current_account.id }

    # Comments belong to tasks, which belong to projects, which belong to accounts
    can :read, Comment, task: { project: { account_id: current_account.id } }
    can :create, Comment, task: { project: { account_id: current_account.id } }
  end
end
```

## Testing Multi-Tenancy

```ruby
# spec/models/ability_spec.rb
require 'rails_helper'
require 'cancan/matchers'

RSpec.describe Ability, type: :model do
  let(:organization1) { create(:organization) }
  let(:organization2) { create(:organization) }
  let(:user) { create(:user, organization: organization1) }
  let(:post_in_org1) { create(:post, organization: organization1) }
  let(:post_in_org2) { create(:post, organization: organization2) }

  subject(:ability) { Ability.new(user) }

  it 'allows access to own organization resources' do
    expect(ability).to be_able_to(:read, post_in_org1)
  end

  it 'denies access to other organization resources' do
    expect(ability).not_to be_able_to(:read, post_in_org2)
  end

  describe 'with multiple accounts' do
    let(:account1) { create(:account) }
    let(:account2) { create(:account) }
    let(:user) { create(:user) }
    let!(:membership1) { create(:membership, user: user, account: account1, role: :admin) }
    let!(:membership2) { create(:membership, user: user, account: account2, role: :member) }

    it 'has different permissions based on current account' do
      ability_in_account1 = Ability.new(user, account1)
      ability_in_account2 = Ability.new(user, account2)

      expect(ability_in_account1).to be_able_to(:manage, Project.new(account: account1))
      expect(ability_in_account2).not_to be_able_to(:manage, Project.new(account: account2))
    end
  end
end
```

## Common Pitfalls

### 1. Forgetting to Scope Queries

```ruby
# Bad - exposes all organizations' data
def index
  @posts = Post.accessible_by(current_ability)
end

# Good - explicitly scope to current organization
def index
  @posts = current_organization.posts.accessible_by(current_ability)
end
```

### 2. Not Setting Organization on Create

```ruby
# Bad - user could potentially set any organization_id
def create
  @post = Post.new(post_params)
  authorize! :create, @post
end

# Good - always set organization from context
def create
  @post = current_organization.posts.new(post_params)
  @post.user = current_user
  authorize! :create, @post
end
```

### 3. Missing Organization in Nested Resources

```ruby
# app/controllers/comments_controller.rb
class CommentsController < ApplicationController
  before_action :set_post

  def create
    # Verify post belongs to current organization
    authorize! :read, @post

    @comment = @post.comments.build(comment_params)
    @comment.user = current_user

    if @comment.save
      redirect_to @post
    else
      render 'posts/show'
    end
  end

  private

  def set_post
    @post = current_organization.posts.find(params[:post_id])
  end
end
```

## Best Practices

1. **Always scope to tenant**: Use `current_organization.posts` instead of `Post.all`
2. **Set organization on create**: Automatically assign organization from context
3. **Verify nested resources**: Ensure parent resources belong to current tenant
4. **Test cross-tenant access**: Write specs that verify users can't access other tenants' data
5. **Use database constraints**: Add foreign keys and indexes on organization_id
6. **Cache ability per account**: Use `@current_ability ||= Ability.new(current_user, current_account)`
