# OmniAuth Integration with Devise

## Table of Contents
- [Basic Setup](#basic-setup)
- [Provider Configuration](#provider-configuration)
- [User Model Setup](#user-model-setup)
- [Callbacks Controller](#callbacks-controller)
- [Common Providers](#common-providers)
- [Testing OmniAuth](#testing-omniauth)

## Basic Setup

1. Add gems to Gemfile:
```ruby
gem 'omniauth'
gem 'omniauth-rails_csrf_protection'  # Required for OmniAuth 2.0+
gem 'omniauth-google-oauth2'  # or other providers
```

2. Configure in `config/initializers/devise.rb`:
```ruby
config.omniauth :google_oauth2, 
  ENV['GOOGLE_CLIENT_ID'], 
  ENV['GOOGLE_CLIENT_SECRET'],
  scope: 'email,profile'
```

## Provider Configuration

### Google OAuth2
```ruby
config.omniauth :google_oauth2,
  ENV['GOOGLE_CLIENT_ID'],
  ENV['GOOGLE_CLIENT_SECRET'],
  {
    scope: 'email,profile',
    prompt: 'select_account',
    image_aspect_ratio: 'square',
    image_size: 50
  }
```

### Facebook
```ruby
gem 'omniauth-facebook'

config.omniauth :facebook,
  ENV['FACEBOOK_APP_ID'],
  ENV['FACEBOOK_APP_SECRET'],
  scope: 'email,public_profile',
  info_fields: 'email,name,first_name,last_name'
```

### GitHub
```ruby
gem 'omniauth-github'

config.omniauth :github,
  ENV['GITHUB_CLIENT_ID'],
  ENV['GITHUB_CLIENT_SECRET'],
  scope: 'user:email'
```

## User Model Setup

Add `:omniauthable` to User model and create migration:

```bash
rails g migration AddOmniauthToUsers provider:string uid:string
rails db:migrate
```

```ruby
# app/models/user.rb
class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: [:google_oauth2, :facebook, :github]

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      user.password = Devise.friendly_token[0, 20]
      user.name = auth.info.name   # if you have a name column
      # user.avatar = auth.info.image  # if you have avatar column
    end
  end
end
```

## Callbacks Controller

Create `app/controllers/users/omniauth_callbacks_controller.rb`:

```ruby
class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def google_oauth2
    handle_auth("Google")
  end

  def facebook
    handle_auth("Facebook")
  end

  def github
    handle_auth("GitHub")
  end

  def failure
    redirect_to root_path, alert: "Authentication failed: #{failure_message}"
  end

  private

  def handle_auth(provider)
    @user = User.from_omniauth(request.env['omniauth.auth'])

    if @user.persisted?
      sign_in_and_redirect @user, event: :authentication
      set_flash_message(:notice, :success, kind: provider) if is_navigational_format?
    else
      session['devise.auth_data'] = request.env['omniauth.auth'].except(:extra)
      redirect_to new_user_registration_url, alert: @user.errors.full_messages.join("\n")
    end
  end
end
```

Update routes:
```ruby
devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }
```

## View Links

```erb
<%# Sign in links %>
<%= button_to "Sign in with Google", user_google_oauth2_omniauth_authorize_path, data: { turbo: false } %>
<%= button_to "Sign in with Facebook", user_facebook_omniauth_authorize_path, data: { turbo: false } %>
<%= button_to "Sign in with GitHub", user_github_omniauth_authorize_path, data: { turbo: false } %>
```

Note: Use `button_to` (POST) instead of `link_to` (GET) for OmniAuth 2.0+ security.

## Handling Existing Users

To allow linking OAuth to existing accounts:

```ruby
def self.from_omniauth(auth)
  user = where(email: auth.info.email).first

  if user
    user.update(provider: auth.provider, uid: auth.uid) unless user.provider
    user
  else
    where(provider: auth.provider, uid: auth.uid).first_or_create do |new_user|
      new_user.email = auth.info.email
      new_user.password = Devise.friendly_token[0, 20]
      new_user.name = auth.info.name
    end
  end
end
```

## Testing OmniAuth

In `spec/rails_helper.rb` or test setup:

```ruby
OmniAuth.config.test_mode = true

OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new({
  provider: 'google_oauth2',
  uid: '123456789',
  info: {
    email: 'test@example.com',
    name: 'Test User',
    image: 'https://example.com/image.jpg'
  },
  credentials: {
    token: 'mock_token',
    refresh_token: 'mock_refresh_token',
    expires_at: Time.now + 1.week
  }
})
```

Reset after tests:
```ruby
after(:each) do
  OmniAuth.config.mock_auth[:google_oauth2] = nil
end
```
