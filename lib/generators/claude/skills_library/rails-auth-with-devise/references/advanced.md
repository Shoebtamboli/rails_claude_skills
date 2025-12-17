# Advanced Devise Patterns

## Table of Contents
- [Multiple User Models](#multiple-user-models)
- [Email Confirmation](#email-confirmation)
- [Account Locking](#account-locking)
- [Password Complexity](#password-complexity)
- [Custom Authentication Logic](#custom-authentication-logic)
- [Soft Delete Users](#soft-delete-users)
- [Background Email Delivery](#background-email-delivery)
- [I18n Configuration](#i18n-configuration)

## Multiple User Models

### Setup Admin Alongside User

```bash
rails generate devise Admin
rails db:migrate
```

Each model gets separate routes and helpers:
```ruby
# Routes
devise_for :users
devise_for :admins

# Controllers
before_action :authenticate_user!   # for users
before_action :authenticate_admin!  # for admins

# Helpers
user_signed_in?   / current_user   / user_session
admin_signed_in?  / current_admin  / admin_session
```

### Scoped Views

Enable in initializer:
```ruby
# config/initializers/devise.rb
config.scoped_views = true
```

Generate scoped views:
```bash
rails generate devise:views users
rails generate devise:views admins
```

Views will be in `app/views/users/` and `app/views/admins/`.

## Email Confirmation

### Enable Confirmable

1. Add to model:
```ruby
devise :database_authenticatable, :registerable, :confirmable
```

2. Add migration columns:
```bash
rails g migration AddConfirmableToUsers confirmation_token:string confirmed_at:datetime confirmation_sent_at:datetime unconfirmed_email:string
```

```ruby
class AddConfirmableToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :confirmation_token, :string
    add_column :users, :confirmed_at, :datetime
    add_column :users, :confirmation_sent_at, :datetime
    add_column :users, :unconfirmed_email, :string
    add_index :users, :confirmation_token, unique: true

    # Confirm existing users
    User.update_all(confirmed_at: Time.current)
  end
end
```

### Customize Confirmation

In `config/initializers/devise.rb`:
```ruby
config.confirm_within = 3.days  # Token valid for 3 days
config.reconfirmable = true     # Require confirmation on email change
config.allow_unconfirmed_access_for = 2.days  # Grace period
```

### Skip Confirmation (Admin-created users)

```ruby
user = User.new(email: 'test@example.com', password: 'password')
user.skip_confirmation!
user.save!
```

## Account Locking

### Enable Lockable

1. Add to model:
```ruby
devise :database_authenticatable, :registerable, :lockable
```

2. Add migration:
```bash
rails g migration AddLockableToUsers failed_attempts:integer unlock_token:string locked_at:datetime
```

```ruby
class AddLockableToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :failed_attempts, :integer, default: 0, null: false
    add_column :users, :unlock_token, :string
    add_column :users, :locked_at, :datetime
    add_index :users, :unlock_token, unique: true
  end
end
```

### Configuration

```ruby
# config/initializers/devise.rb
config.lock_strategy = :failed_attempts
config.unlock_keys = [:email]
config.unlock_strategy = :both  # :email, :time, or :both
config.maximum_attempts = 5
config.unlock_in = 1.hour
```

## Password Complexity

### Basic Validation

```ruby
# app/models/user.rb
validate :password_complexity

private

def password_complexity
  return if password.blank?
  
  unless password.match?(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/)
    errors.add :password, 'must include at least one lowercase letter, one uppercase letter, and one digit'
  end
end
```

### Using devise-security Gem

```ruby
# Gemfile
gem 'devise-security'

# app/models/user.rb
devise :password_archivable, :password_expirable, :secure_validatable
```

## Custom Authentication Logic

### Sign in with Username OR Email

```ruby
# config/initializers/devise.rb
config.authentication_keys = [:login]

# app/models/user.rb
attr_accessor :login

def self.find_for_database_authentication(warden_conditions)
  conditions = warden_conditions.dup
  if (login = conditions.delete(:login))
    where(conditions.to_h).where(
      ['lower(username) = :value OR lower(email) = :value', { value: login.downcase }]
    ).first
  elsif conditions.key?(:username) || conditions.key?(:email)
    where(conditions.to_h).first
  end
end
```

Update views to use `:login` instead of `:email`.

### Custom Account Validation

```ruby
# app/models/user.rb
def active_for_authentication?
  super && approved? && !banned?
end

def inactive_message
  if !approved?
    :not_approved
  elsif banned?
    :banned
  else
    super
  end
end
```

Add to locale:
```yaml
# config/locales/devise.en.yml
en:
  devise:
    failure:
      not_approved: "Your account has not been approved yet."
      banned: "Your account has been banned."
```

## Soft Delete Users

Using `discard` or `paranoia` gem:

```ruby
# app/models/user.rb
include Discard::Model

def active_for_authentication?
  super && !discarded?
end

def inactive_message
  discarded? ? :account_deleted : super
end

# Override destroy in registrations controller
# app/controllers/users/registrations_controller.rb
class Users::RegistrationsController < Devise::RegistrationsController
  def destroy
    resource.discard
    Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name)
    set_flash_message! :notice, :destroyed
    yield resource if block_given?
    respond_with_navigational(resource){ redirect_to after_sign_out_path_for(resource_name) }
  end
end
```

## Background Email Delivery

### Using Active Job

```ruby
# app/models/user.rb
def send_devise_notification(notification, *args)
  devise_mailer.send(notification, self, *args).deliver_later
end
```

### With Queue Priority

```ruby
def send_devise_notification(notification, *args)
  devise_mailer.send(notification, self, *args).deliver_later(queue: :high_priority)
end
```

## I18n Configuration

### Flash Messages

```yaml
# config/locales/devise.en.yml
en:
  devise:
    sessions:
      signed_in: "Welcome back!"
      signed_out: "Goodbye!"
      already_signed_out: "You're already signed out."
    registrations:
      signed_up: "Welcome! You have signed up successfully."
      signed_up_but_unconfirmed: "Please check your email to confirm your account."
      updated: "Your account has been updated successfully."
      destroyed: "Your account has been deleted. We're sorry to see you go!"
    passwords:
      send_instructions: "You will receive an email with instructions shortly."
      updated: "Your password has been changed successfully."
    confirmations:
      confirmed: "Your email has been confirmed."
      send_instructions: "Confirmation instructions sent."
    unlocks:
      send_instructions: "Unlock instructions sent."
      unlocked: "Your account has been unlocked."
    mailer:
      confirmation_instructions:
        subject: "Confirm your email"
      reset_password_instructions:
        subject: "Reset your password"
      unlock_instructions:
        subject: "Unlock your account"
```

### Per-Resource Messages

```yaml
en:
  devise:
    sessions:
      user:
        signed_in: "Welcome, user!"
      admin:
        signed_in: "Welcome back, administrator!"
```

## Customizing Mailer

```ruby
# app/mailers/custom_devise_mailer.rb
class CustomDeviseMailer < Devise::Mailer
  helper :application
  include Devise::Controllers::UrlHelpers
  default template_path: 'devise/mailer'
  layout 'mailer'

  def confirmation_instructions(record, token, opts = {})
    opts[:subject] = "Welcome to MyApp - Please confirm your email"
    super
  end
end

# config/initializers/devise.rb
config.mailer = 'CustomDeviseMailer'
```
