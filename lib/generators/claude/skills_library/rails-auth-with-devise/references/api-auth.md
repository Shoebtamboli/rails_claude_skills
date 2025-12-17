# API Authentication with Devise

## Table of Contents
- [Rails API Mode Setup](#rails-api-mode-setup)
- [HTTP Basic Authentication](#http-basic-authentication)
- [Token Authentication](#token-authentication)
- [JWT Authentication](#jwt-authentication)
- [Testing API Authentication](#testing-api-authentication)

## Rails API Mode Setup

For `rails new myapp --api` applications:

### Enable Required Middleware

In `config/application.rb`:
```ruby
config.middleware.use ActionDispatch::Cookies
config.middleware.use ActionDispatch::Session::CookieStore
```

Or for testing only in `config/environments/test.rb`:
```ruby
Rails.application.config.middleware.insert_before Warden::Manager, ActionDispatch::Cookies
Rails.application.config.middleware.insert_before Warden::Manager, ActionDispatch::Session::CookieStore
```

### Disable Views

In `config/initializers/devise.rb`:
```ruby
config.navigational_formats = []
```

## HTTP Basic Authentication

Enable in initializer:
```ruby
# config/initializers/devise.rb
config.http_authenticatable = [:database]
```

Usage:
```bash
curl -u user@example.com:password http://localhost:3000/api/resource
```

## Token Authentication

### Simple Token Setup

1. Add token column:
```bash
rails g migration AddAuthenticationTokenToUsers authentication_token:string:index
rails db:migrate
```

2. Configure User model:
```ruby
class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  before_save :ensure_authentication_token

  def ensure_authentication_token
    self.authentication_token ||= generate_authentication_token
  end

  def regenerate_authentication_token!
    self.authentication_token = generate_authentication_token
    save!
  end

  private

  def generate_authentication_token
    loop do
      token = Devise.friendly_token
      break token unless User.exists?(authentication_token: token)
    end
  end
end
```

3. Create token authentication concern:
```ruby
# app/controllers/concerns/api_authenticatable.rb
module ApiAuthenticatable
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_with_token!
  end

  private

  def authenticate_with_token!
    authenticate_or_request_with_http_token do |token, _options|
      @current_user = User.find_by(authentication_token: token)
    end
  end

  def current_user
    @current_user
  end
end
```

4. Use in API controller:
```ruby
class Api::V1::BaseController < ActionController::API
  include ApiAuthenticatable
end
```

Usage:
```bash
curl -H "Authorization: Token token=YOUR_TOKEN" http://localhost:3000/api/v1/resource
```

## JWT Authentication

Use `devise-jwt` gem for JWT-based authentication:

1. Add gems:
```ruby
gem 'devise-jwt'
```

2. Configure secret:
```ruby
# config/initializers/devise.rb
Devise.setup do |config|
  config.jwt do |jwt|
    jwt.secret = Rails.application.credentials.devise_jwt_secret_key!
    jwt.dispatch_requests = [
      ['POST', %r{^/login$}]
    ]
    jwt.revocation_requests = [
      ['DELETE', %r{^/logout$}]
    ]
    jwt.expiration_time = 1.day.to_i
  end
end
```

3. Set up revocation strategy:
```ruby
# app/models/user.rb
class User < ApplicationRecord
  include Devise::JWT::RevocationStrategies::JTIMatcher

  devise :database_authenticatable, :registerable,
         :jwt_authenticatable, jwt_revocation_strategy: self
end
```

4. Add JTI column:
```bash
rails g migration AddJtiToUsers jti:string:index:unique
rails db:migrate
```

Update migration to add NOT NULL and default:
```ruby
add_column :users, :jti, :string, null: false, default: ""
add_index :users, :jti, unique: true
```

5. Create sessions controller:
```ruby
# app/controllers/api/v1/sessions_controller.rb
class Api::V1::SessionsController < Devise::SessionsController
  respond_to :json

  private

  def respond_with(resource, _opts = {})
    render json: { user: resource, token: request.env['warden-jwt_auth.token'] }
  end

  def respond_to_on_destroy
    head :no_content
  end
end
```

6. Routes:
```ruby
devise_for :users, path: '', path_names: {
  sign_in: 'login',
  sign_out: 'logout',
  registration: 'signup'
}, controllers: {
  sessions: 'api/v1/sessions',
  registrations: 'api/v1/registrations'
}
```

Usage:
```bash
# Login
curl -X POST http://localhost:3000/login \
  -H "Content-Type: application/json" \
  -d '{"user":{"email":"user@example.com","password":"password"}}'

# Use token
curl http://localhost:3000/api/v1/resource \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

## API Response Format

Create consistent JSON responses:

```ruby
# app/controllers/api/v1/registrations_controller.rb
class Api::V1::RegistrationsController < Devise::RegistrationsController
  respond_to :json

  private

  def respond_with(resource, _opts = {})
    if resource.persisted?
      render json: {
        status: { code: 200, message: 'Signed up successfully.' },
        data: UserSerializer.new(resource).serializable_hash[:data][:attributes]
      }
    else
      render json: {
        status: { code: 422, message: "User couldn't be created." },
        errors: resource.errors.full_messages
      }, status: :unprocessable_entity
    end
  end
end
```

## Testing API Authentication

```ruby
# spec/support/api_helpers.rb
module ApiHelpers
  def auth_headers(user)
    token = Warden::JWTAuth::UserEncoder.new.call(user, :user, nil).first
    { 'Authorization' => "Bearer #{token}" }
  end
end

RSpec.configure do |config|
  config.include ApiHelpers, type: :request
end
```

Usage in tests:
```ruby
describe 'GET /api/v1/profile' do
  let(:user) { create(:user) }

  it 'returns user profile' do
    get '/api/v1/profile', headers: auth_headers(user)
    expect(response).to have_http_status(:ok)
  end
end
```
