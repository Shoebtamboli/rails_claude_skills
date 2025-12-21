# API Authorization with CanCanCan

Implementing authorization for JSON APIs with CanCanCan, including token-based auth and proper error handling.

## Basic API Setup

### API Base Controller

```ruby
# app/controllers/api/v1/base_controller.rb
module Api
  module V1
    class BaseController < ActionController::API
      before_action :authenticate_api_user!

      rescue_from CanCan::AccessDenied do |exception|
        render json: {
          error: 'Forbidden',
          message: exception.message
        }, status: :forbidden
      end

      private

      def authenticate_api_user!
        token = request.headers['Authorization']&.split(' ')&.last
        @current_user = User.find_by(api_token: token)

        render json: { error: 'Unauthorized' }, status: :unauthorized unless @current_user
      end

      def current_user
        @current_user
      end

      def current_ability
        @current_ability ||= Ability.new(current_user)
      end
    end
  end
end
```

### API Resource Controller

```ruby
# app/controllers/api/v1/posts_controller.rb
module Api
  module V1
    class PostsController < BaseController
      load_and_authorize_resource

      def index
        render json: @posts
      end

      def show
        render json: @post
      end

      def create
        if @post.save
          render json: @post, status: :created
        else
          render json: { errors: @post.errors }, status: :unprocessable_entity
        end
      end

      def update
        if @post.update(post_params)
          render json: @post
        else
          render json: { errors: @post.errors }, status: :unprocessable_entity
        end
      end

      def destroy
        @post.destroy
        head :no_content
      end

      private

      def post_params
        params.require(:post).permit(:title, :body, :published)
      end
    end
  end
end
```

## JWT Authentication

### Setup with devise-jwt

```ruby
# Gemfile
gem 'devise'
gem 'devise-jwt'

# app/models/user.rb
class User < ApplicationRecord
  devise :database_authenticatable,
         :jwt_authenticatable,
         jwt_revocation_strategy: JwtDenylist
end

# app/models/jwt_denylist.rb
class JwtDenylist < ApplicationRecord
  include Devise::JWT::RevocationStrategies::Denylist

  self.table_name = 'jwt_denylist'
end
```

### API Controller with JWT

```ruby
# app/controllers/api/v1/base_controller.rb
module Api
  module V1
    class BaseController < ActionController::API
      before_action :authenticate_user!

      rescue_from CanCan::AccessDenied do |exception|
        render json: {
          error: 'Forbidden',
          message: exception.message,
          action: exception.action,
          subject: exception.subject.class.name
        }, status: :forbidden
      end

      def current_ability
        @current_ability ||= Ability.new(current_user)
      end
    end
  end
end
```

## Token-Based Authorization

### Simple Token Authentication

```ruby
# app/models/user.rb
class User < ApplicationRecord
  has_secure_token :api_token

  def regenerate_api_token
    regenerate_api_token!
  end
end

# Migration
class AddApiTokenToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :api_token, :string
    add_index :users, :api_token, unique: true
  end
end
```

### Token Authentication Controller

```ruby
# app/controllers/api/v1/authentication_controller.rb
module Api
  module V1
    class AuthenticationController < ActionController::API
      def create
        user = User.find_by(email: params[:email])

        if user&.authenticate(params[:password])
          render json: {
            token: user.api_token,
            user: {
              id: user.id,
              email: user.email,
              role: user.role
            }
          }
        else
          render json: { error: 'Invalid credentials' }, status: :unauthorized
        end
      end

      def destroy
        current_user.regenerate_api_token
        head :no_content
      end
    end
  end
end
```

## Granular API Permissions

### API-Specific Abilities

```ruby
# app/models/ability.rb
class Ability
  include CanCan::Ability

  def initialize(user, options = {})
    return unless user.present?

    # Different permissions for API vs web
    if options[:api]
      define_api_abilities(user)
    else
      define_web_abilities(user)
    end
  end

  private

  def define_api_abilities(user)
    # API users have more restricted access
    can :read, Post, published: true
    can :read, Post, user_id: user.id

    if user.api_access_level == 'full'
      can :create, Post
      can :update, Post, user_id: user.id
      can :destroy, Post, user_id: user.id
    end

    # Admins have full API access
    can :manage, :all if user.admin?
  end

  def define_web_abilities(user)
    # Web users have standard access
    can :read, Post
    can :create, Post
    can :update, Post, user_id: user.id
    can :destroy, Post, user_id: user.id

    can :manage, :all if user.admin?
  end
end

# app/controllers/api/v1/base_controller.rb
def current_ability
  @current_ability ||= Ability.new(current_user, api: true)
end
```

## Scoped API Keys

### Per-Resource API Keys

```ruby
# app/models/api_key.rb
class ApiKey < ApplicationRecord
  belongs_to :user

  enum scope: {
    read_only: 0,
    read_write: 1,
    admin: 2
  }

  has_secure_token :token

  def can_write?
    read_write? || admin?
  end
end

# app/models/ability.rb
class Ability
  include CanCan::Ability

  def initialize(user, api_key: nil)
    return unless user.present?

    if api_key
      define_api_key_abilities(user, api_key)
    else
      define_standard_abilities(user)
    end
  end

  private

  def define_api_key_abilities(user, api_key)
    case api_key.scope
    when 'read_only'
      can :read, Post, user_id: user.id
    when 'read_write'
      can :read, Post
      can [:create, :update], Post, user_id: user.id
    when 'admin'
      can :manage, :all
    end
  end
end

# app/controllers/api/v1/base_controller.rb
def authenticate_api_user!
  token = request.headers['Authorization']&.split(' ')&.last
  @api_key = ApiKey.find_by(token: token)

  if @api_key
    @current_user = @api_key.user
  else
    render json: { error: 'Unauthorized' }, status: :unauthorized
  end
end

def current_ability
  @current_ability ||= Ability.new(current_user, api_key: @api_key)
end
```

## Rate Limiting with Authorization

```ruby
# app/controllers/api/v1/base_controller.rb
module Api
  module V1
    class BaseController < ActionController::API
      before_action :authenticate_api_user!
      before_action :check_rate_limit

      private

      def check_rate_limit
        if current_user.admin?
          # Admins have higher rate limits
          rate_limit = 1000
        elsif can? :manage, Post
          # Power users
          rate_limit = 500
        else
          # Regular users
          rate_limit = 100
        end

        # Implement rate limiting logic
        # (using Redis, rack-attack, etc.)
      end
    end
  end
end
```

## Error Handling and Responses

### Detailed Error Messages

```ruby
# app/controllers/api/v1/base_controller.rb
rescue_from CanCan::AccessDenied do |exception|
  render json: {
    error: {
      type: 'Forbidden',
      message: exception.message,
      details: {
        action: exception.action,
        subject: exception.subject.class.name,
        subject_id: exception.subject.try(:id)
      }
    }
  }, status: :forbidden
end

# Example response:
# {
#   "error": {
#     "type": "Forbidden",
#     "message": "You are not authorized to update this Post",
#     "details": {
#       "action": "update",
#       "subject": "Post",
#       "subject_id": 123
#     }
#   }
# }
```

### Custom Authorization Messages

```ruby
# app/controllers/api/v1/posts_controller.rb
def update
  authorize! :update, @post, message: "You can only edit your own posts"

  if @post.update(post_params)
    render json: @post
  else
    render json: { errors: @post.errors }, status: :unprocessable_entity
  end
end
```

## Testing API Authorization

### Request Specs

```ruby
# spec/requests/api/v1/posts_spec.rb
require 'rails_helper'

RSpec.describe 'Api::V1::Posts', type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:headers) { { 'Authorization' => "Bearer #{user.api_token}" } }

  describe 'GET /api/v1/posts' do
    let!(:posts) { create_list(:post, 3, user: user) }

    it 'returns authorized posts' do
      get '/api/v1/posts', headers: headers
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body).size).to eq(3)
    end

    it 'requires authentication' do
      get '/api/v1/posts'
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'PUT /api/v1/posts/:id' do
    let(:post) { create(:post, user: user) }
    let(:other_post) { create(:post, user: other_user) }

    it 'allows updating own post' do
      put "/api/v1/posts/#{post.id}",
          params: { post: { title: 'New Title' } },
          headers: headers

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['title']).to eq('New Title')
    end

    it 'denies updating other user post' do
      put "/api/v1/posts/#{other_post.id}",
          params: { post: { title: 'New Title' } },
          headers: headers

      expect(response).to have_http_status(:forbidden)
      expect(JSON.parse(response.body)).to have_key('error')
    end
  end
end
```

### Testing Different API Key Scopes

```ruby
# spec/requests/api/v1/posts_with_api_keys_spec.rb
RSpec.describe 'Api::V1::Posts with API keys', type: :request do
  let(:user) { create(:user) }
  let(:read_only_key) { create(:api_key, user: user, scope: :read_only) }
  let(:read_write_key) { create(:api_key, user: user, scope: :read_write) }

  describe 'with read-only key' do
    let(:headers) { { 'Authorization' => "Bearer #{read_only_key.token}" } }

    it 'allows reading posts' do
      get '/api/v1/posts', headers: headers
      expect(response).to have_http_status(:ok)
    end

    it 'denies creating posts' do
      post '/api/v1/posts',
           params: { post: { title: 'Test' } },
           headers: headers

      expect(response).to have_http_status(:forbidden)
    end
  end

  describe 'with read-write key' do
    let(:headers) { { 'Authorization' => "Bearer #{read_write_key.token}" } }

    it 'allows creating posts' do
      post '/api/v1/posts',
           params: { post: { title: 'Test', body: 'Content' } },
           headers: headers

      expect(response).to have_http_status(:created)
    end
  end
end
```

## GraphQL Integration

```ruby
# app/graphql/types/query_type.rb
module Types
  class QueryType < Types::BaseObject
    field :posts, [Types::PostType], null: false

    def posts
      Post.accessible_by(context[:current_ability])
    end
  end
end

# app/graphql/mutations/create_post.rb
module Mutations
  class CreatePost < BaseMutation
    argument :title, String, required: true
    argument :body, String, required: true

    field :post, Types::PostType, null: true
    field :errors, [String], null: false

    def resolve(title:, body:)
      post = Post.new(title: title, body: body, user: context[:current_user])

      context[:current_ability].authorize! :create, post

      if post.save
        { post: post, errors: [] }
      else
        { post: nil, errors: post.errors.full_messages }
      end
    end
  end
end
```

## Best Practices for API Authorization

1. **Always authenticate API requests**: Never skip authentication for API endpoints
2. **Use HTTPS**: Always use SSL/TLS for API requests with sensitive tokens
3. **Implement rate limiting**: Protect against abuse based on user abilities
4. **Return proper HTTP status codes**: 401 for unauthenticated, 403 for unauthorized
5. **Provide clear error messages**: Help API consumers understand authorization failures
6. **Version your API**: Include authorization changes in API versioning
7. **Log authorization failures**: Track unauthorized access attempts
8. **Use scoped tokens**: Limit token permissions to minimum required access
9. **Implement token expiration**: Refresh tokens periodically
10. **Test authorization thoroughly**: Cover all permission scenarios in specs
