## Rails Deployment Examples

Complete deployment patterns and examples for production Rails applications with Kamal.

---

## Kamal Configuration

### Basic Single-Server Setup

```yaml
# config/deploy.yml
service: my-blog-app
image: username/my-blog-app

servers:
  web:
    hosts:
      - 192.168.1.100
    labels:
      traefik.http.routers.my-blog-app.rule: Host(`blog.example.com`)
      traefik.http.routers.my-blog-app-secure.entrypoints: websecure
      traefik.http.routers.my-blog-app-secure.rule: Host(`blog.example.com`)
      traefik.http.routers.my-blog-app-secure.tls: true
      traefik.http.routers.my-blog-app-secure.tls.certresolver: letsencrypt

registry:
  username: username
  password:
    - KAMAL_REGISTRY_PASSWORD

env:
  secret:
    - RAILS_MASTER_KEY
  clear:
    RAILS_ENV: production
    RAILS_LOG_TO_STDOUT: enabled
    RAILS_SERVE_STATIC_FILES: enabled

builder:
  arch: amd64
  remote:
    host: 192.168.1.100

traefik:
  options:
    publish:
      - 443:443
      - 80:80
    volume:
      - "/letsencrypt:/letsencrypt"
  args:
    entryPoints.web.address: ":80"
    entryPoints.websecure.address: ":443"
    certificatesResolvers.letsencrypt.acme.email: "admin@example.com"
    certificatesResolvers.letsencrypt.acme.storage: "/letsencrypt/acme.json"
    certificatesResolvers.letsencrypt.acme.httpchallenge: true
    certificatesResolvers.letsencrypt.acme.httpchallenge.entrypoint: web

healthcheck:
  path: /up
  port: 3000
  max_attempts: 10
  interval: 10s
```

### Multi-Server Setup with Load Balancing

```yaml
# config/deploy.yml
service: my-app
image: username/my-app

servers:
  web:
    hosts:
      - 192.168.1.101
      - 192.168.1.102
      - 192.168.1.103
    labels:
      traefik.http.routers.my-app.rule: Host(`app.example.com`)
      traefik.http.routers.my-app-secure.entrypoints: websecure
      traefik.http.routers.my-app-secure.rule: Host(`app.example.com`)
      traefik.http.routers.my-app-secure.tls: true
      traefik.http.routers.my-app-secure.tls.certresolver: letsencrypt
    options:
      network: "private"

  # Separate worker servers for background jobs
  workers:
    hosts:
      - 192.168.1.104
      - 192.168.1.105
    cmd: bundle exec rake solid_queue:start
    options:
      network: "private"

registry:
  username: username
  password:
    - KAMAL_REGISTRY_PASSWORD

env:
  secret:
    - RAILS_MASTER_KEY
    - DATABASE_URL
  clear:
    RAILS_ENV: production
    RAILS_LOG_TO_STDOUT: enabled
    WEB_CONCURRENCY: 3
    RAILS_MAX_THREADS: 5

builder:
  arch: amd64

traefik:
  host_port: 192.168.1.100  # Dedicated load balancer
  options:
    publish:
      - 443:443
      - 80:80
    volume:
      - "/letsencrypt:/letsencrypt"
    network: "private"
  args:
    entryPoints.web.address: ":80"
    entryPoints.websecure.address: ":443"
    certificatesResolvers.letsencrypt.acme.email: "admin@example.com"
    certificatesResolvers.letsencrypt.acme.storage: "/letsencrypt/acme.json"
    certificatesResolvers.letsencrypt.acme.httpchallenge: true
    certificatesResolvers.letsencrypt.acme.httpchallenge.entrypoint: web

healthcheck:
  path: /up
  port: 3000
  max_attempts: 10
  interval: 10s
```

### Staging + Production Environments

```yaml
# config/deploy.yml (production)
service: my-app-production
image: username/my-app

servers:
  web:
    hosts:
      - production.example.com
    labels:
      traefik.http.routers.my-app-prod.rule: Host(`app.example.com`)

env:
  secret:
    - RAILS_MASTER_KEY
  clear:
    RAILS_ENV: production
```

```yaml
# config/deploy.staging.yml (staging)
service: my-app-staging
image: username/my-app

servers:
  web:
    hosts:
      - staging.example.com
    labels:
      traefik.http.routers.my-app-staging.rule: Host(`staging.app.example.com`)

env:
  secret:
    - RAILS_MASTER_KEY
  clear:
    RAILS_ENV: staging
```

```bash
# Deploy to staging
kamal deploy -c config/deploy.staging.yml

# Deploy to production
kamal deploy -c config/deploy.yml
```

---

## Docker Configuration

### Optimized Multi-Stage Dockerfile

```dockerfile
# syntax = docker/dockerfile:1

ARG RUBY_VERSION=3.4.7
FROM ruby:$RUBY_VERSION-slim AS base

# Set working directory
WORKDIR /rails

# Install base packages
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    curl \
    libjemalloc2 \
    libvips \
    sqlite3 && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Set production environment
ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development:test" \
    MALLOC_CONF="background_thread:true,metadata_thp:auto,dirty_decay_ms:5000,muzzy_decay_ms:5000"

# Build stage
FROM base AS build

# Install build packages
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    build-essential \
    git \
    pkg-config && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Install gems
COPY Gemfile Gemfile.lock ./
RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
    bundle exec bootsnap precompile --gemfile

# Copy application code
COPY . .

# Precompile bootsnap code for faster boot times
RUN bundle exec bootsnap precompile app/ lib/

# Precompile assets
RUN SECRET_KEY_BASE_DUMMY=1 ./bin/rails assets:precompile

# Final stage
FROM base

# Copy built artifacts
COPY --from=build "${BUNDLE_PATH}" "${BUNDLE_PATH}"
COPY --from=build /rails /rails

# Create user
RUN groupadd --system --gid 1000 rails && \
    useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash && \
    chown -R rails:rails db log storage tmp
USER 1000:1000

# Entrypoint
ENTRYPOINT ["/rails/bin/docker-entrypoint"]

EXPOSE 3000
CMD ["./bin/thrust", "./bin/rails", "server"]
```

### Docker Entrypoint Script

```bash
#!/bin/bash -e
# bin/docker-entrypoint

# Remove pre-existing server.pid
rm -f /rails/tmp/pids/server.pid

# Run migrations if DATABASE_URL is set
if [ -n "$DATABASE_URL" ]; then
  echo "Running database migrations..."
  bundle exec rails db:prepare
fi

# Execute CMD
exec "${@}"
```

```bash
# Make executable
chmod +x bin/docker-entrypoint
```

### .dockerignore

```
# .dockerignore
.git
.github
.gitignore
.dockerignore

# Development/Test
.env*
!.env.example
coverage/
log/*
tmp/*
*.log
*.pid

# Documentation
README.md
CHANGELOG.md
doc/

# Dependencies
node_modules/
vendor/bundle/

# Build artifacts
public/assets/
public/packs/

# IDE
.idea/
.vscode/
*.swp
*.swo
```

---

## Environment Secrets

### Using Rails Credentials

```bash
# Edit production credentials
EDITOR=nano rails credentials:edit --environment production

# Save to config/credentials/production.key (keep secure, don't commit)
```

```yaml
# config/credentials/production.yml.enc (encrypted, safe to commit)
secret_key_base: abc123...

database:
  host: db.example.com
  username: myapp_prod
  password: secure_password

smtp:
  address: smtp.sendgrid.net
  username: apikey
  password: SG.xxx

aws:
  access_key_id: AKIA...
  secret_access_key: xxx

stripe:
  publishable_key: pk_live_...
  secret_key: sk_live_...
```

```ruby
# config/database.yml
production:
  <<: *default
  host: <%= Rails.application.credentials.dig(:database, :host) %>
  database: <%= ENV.fetch("DATABASE_NAME", "myapp_production") %>
  username: <%= Rails.application.credentials.dig(:database, :username) %>
  password: <%= Rails.application.credentials.dig(:database, :password) %>
```

### Using Environment Variables

```ruby
# .env (local only, not committed)
KAMAL_REGISTRY_PASSWORD=docker_hub_password
RAILS_MASTER_KEY=abc123...
DATABASE_URL=postgresql://user:pass@host:5432/dbname
SMTP_USERNAME=apikey
SMTP_PASSWORD=sendgrid_key
```

```yaml
# config/deploy.yml
env:
  secret:
    - RAILS_MASTER_KEY
    - DATABASE_URL
    - SMTP_USERNAME
    - SMTP_PASSWORD
  clear:
    RAILS_ENV: production
    RAILS_LOG_TO_STDOUT: enabled
    RAILS_SERVE_STATIC_FILES: enabled
```

---

## Database Deployment

### PostgreSQL with External Database

```yaml
# config/deploy.yml
env:
  secret:
    - DATABASE_URL  # postgresql://user:pass@host:5432/dbname
```

```ruby
# config/database.yml
production:
  <<: *default
  url: <%= ENV["DATABASE_URL"] %>
  pool: <%= ENV.fetch("RAILS_MAX_THREADS", 5) %>
```

### SQLite with Docker Volumes

```yaml
# config/deploy.yml
volumes:
  - "/var/lib/myapp/storage:/rails/storage"
  - "/var/lib/myapp/db:/rails/db"
```

```ruby
# config/database.yml
production:
  <<: *default
  database: db/production.sqlite3
```

### Safe Migration Strategy

```bash
# 1. Deploy code without pushing (uses existing image)
kamal deploy --skip-push

# 2. Check migration status
kamal app exec "bin/rails db:migrate:status"

# 3. Run migrations
kamal app exec "bin/rails db:migrate"

# 4. Verify success
kamal app exec "bin/rails db:version"

# 5. If issues, rollback migration
kamal app exec "bin/rails db:rollback"
```

### Pre-Deployment Migration Hook

```yaml
# config/deploy.yml
hooks:
  pre-deploy:
    - path: config/deploy/hooks/pre-deploy.sh
      on_error: abort
```

```bash
# config/deploy/hooks/pre-deploy.sh
#!/bin/bash
set -e

echo "Running database migrations..."
kamal app exec "bin/rails db:migrate"

echo "Migrations complete!"
```

---

## SSL/TLS Configuration

### Let's Encrypt (Automatic)

```yaml
# config/deploy.yml
traefik:
  options:
    publish:
      - 443:443
      - 80:80
    volume:
      - "/letsencrypt:/letsencrypt"
  args:
    entryPoints.web.address: ":80"
    entryPoints.web.http.redirections.entryPoint.to: websecure
    entryPoints.web.http.redirections.entryPoint.scheme: https
    entryPoints.websecure.address: ":443"
    certificatesResolvers.letsencrypt.acme.email: "admin@example.com"
    certificatesResolvers.letsencrypt.acme.storage: "/letsencrypt/acme.json"
    certificatesResolvers.letsencrypt.acme.httpchallenge: true
    certificatesResolvers.letsencrypt.acme.httpchallenge.entrypoint: web

servers:
  web:
    labels:
      traefik.http.routers.myapp-secure.tls.certresolver: letsencrypt
```

### Custom SSL Certificate

```yaml
# config/deploy.yml
traefik:
  options:
    publish:
      - 443:443
      - 80:80
    volume:
      - "/etc/ssl/certs:/certs:ro"
  args:
    entryPoints.web.address: ":80"
    entryPoints.websecure.address: ":443"
    providers.file.filename: /etc/traefik/tls.yml

# Upload certificates to server
# /etc/traefik/tls.yml:
# tls:
#   certificates:
#     - certFile: /certs/example.com.crt
#       keyFile: /certs/example.com.key
```

---

## Health Checks

### Health Check Endpoint

```ruby
# config/routes.rb
Rails.application.routes.draw do
  get "up", to: "health#show", as: :health_check
end

# app/controllers/health_controller.rb
class HealthController < ApplicationController
  skip_before_action :authenticate_user!

  def show
    # Check database connectivity
    ActiveRecord::Base.connection.execute("SELECT 1")

    # Check Solid Queue
    SolidQueue::Job.count

    # All checks passed
    render json: {
      status: "ok",
      timestamp: Time.current,
      version: ENV["APP_VERSION"]
    }, status: :ok
  rescue StandardError => e
    render json: {
      status: "error",
      error: e.message
    }, status: :service_unavailable
  end
end
```

```yaml
# config/deploy.yml
healthcheck:
  path: /up
  port: 3000
  max_attempts: 10
  interval: 10s
  timeout: 5s
```

---

## Background Jobs Deployment

### Solid Queue Workers

```yaml
# config/deploy.yml
servers:
  web:
    hosts:
      - web1.example.com
      - web2.example.com

  workers:
    hosts:
      - worker1.example.com
      - worker2.example.com
    cmd: bundle exec rake solid_queue:start
    options:
      network: "private"
```

```ruby
# config/recurring.yml (Solid Queue recurring tasks)
production:
  cleanup_old_jobs:
    class: CleanupJob
    schedule: "0 2 * * *"  # Daily at 2 AM
    queue: maintenance

  send_daily_digest:
    class: DailyDigestJob
    schedule: "0 8 * * *"  # Daily at 8 AM
    queue: mailers
```

---

## Rollback Procedures

### Rolling Back Deployment

```bash
# List deployed versions
kamal app version

# Rollback to previous version
kamal rollback <VERSION>

# Example
kamal rollback 20240115123456
```

### Database Rollback

```bash
# Check migration status
kamal app exec "bin/rails db:migrate:status"

# Rollback last migration
kamal app exec "bin/rails db:rollback"

# Rollback multiple migrations
kamal app exec "bin/rails db:rollback STEP=3"

# Rollback to specific version
kamal app exec "bin/rails db:migrate:down VERSION=20240115123456"
```

---

## Monitoring & Logging

### Structured Logging with Lograge

```ruby
# Gemfile
gem "lograge"

# config/environments/production.rb
Rails.application.configure do
  # Use Lograge for structured logs
  config.lograge.enabled = true
  config.lograge.formatter = Lograge::Formatters::Json.new

  config.lograge.custom_options = lambda do |event|
    {
      params: event.payload[:params].except("controller", "action"),
      user_id: event.payload[:user_id],
      ip: event.payload[:ip],
      request_id: event.payload[:request_id]
    }
  end
end
```

### Viewing Logs

```bash
# Tail logs from all web servers
kamal app logs -f

# Tail logs from specific server
kamal app logs -f --hosts 192.168.1.101

# View last 100 lines
kamal app logs --lines 100

# Filter logs
kamal app logs -f | grep ERROR
```

### Error Tracking with Sentry

```ruby
# Gemfile
gem "sentry-ruby"
gem "sentry-rails"

# config/initializers/sentry.rb
Sentry.init do |config|
  config.dsn = Rails.application.credentials.dig(:sentry, :dsn)
  config.breadcrumbs_logger = [:active_support_logger, :http_logger]
  config.traces_sample_rate = 0.1
  config.environment = Rails.env
end
```

---

## CI/CD with GitHub Actions

### Automated Deployment Workflow

```yaml
# .github/workflows/deploy.yml
name: Deploy

on:
  push:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Set up Ruby
        uses: ruby/setup-ruby@v1
        with:
          bundler-cache: true

      - name: Run tests
        run: |
          bin/rails test
          bin/rubocop

  deploy:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Set up Ruby
        uses: ruby/setup-ruby@v1
        with:
          bundler-cache: true

      - name: Install Kamal
        run: gem install kamal

      - name: Setup SSH
        uses: webfactory/ssh-agent@v0.8.0
        with:
          ssh-private-key: ${{ secrets.SSH_PRIVATE_KEY }}

      - name: Deploy with Kamal
        env:
          KAMAL_REGISTRY_PASSWORD: ${{ secrets.KAMAL_REGISTRY_PASSWORD }}
          RAILS_MASTER_KEY: ${{ secrets.RAILS_MASTER_KEY }}
        run: |
          kamal deploy
```

### Manual Deployment Workflow

```yaml
# .github/workflows/manual-deploy.yml
name: Manual Deploy

on:
  workflow_dispatch:
    inputs:
      environment:
        description: "Environment to deploy"
        required: true
        type: choice
        options:
          - staging
          - production

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Deploy to ${{ inputs.environment }}
        run: |
          if [ "${{ inputs.environment }}" = "staging" ]; then
            kamal deploy -c config/deploy.staging.yml
          else
            kamal deploy -c config/deploy.yml
          fi
```

---

## Performance Optimization

### Docker Image Optimization

```dockerfile
# Use specific Ruby version
ARG RUBY_VERSION=3.4.7
FROM ruby:$RUBY_VERSION-slim

# Reduce layer count with multi-command RUN
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y pkg1 pkg2 && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Copy only what's needed
COPY Gemfile Gemfile.lock ./
RUN bundle install

# Use .dockerignore to exclude unnecessary files
```

### Production Configuration

```ruby
# config/environments/production.rb
Rails.application.configure do
  # Serve assets via CDN
  config.asset_host = ENV["CDN_HOST"]

  # Enable caching
  config.cache_classes = true
  config.eager_load = true
  config.consider_all_requests_local = false
  config.public_file_server.enabled = ENV["RAILS_SERVE_STATIC_FILES"].present?

  # Compress CSS
  config.assets.css_compressor = :sass

  # Enable Rack::Deflate for gzip compression
  config.middleware.use Rack::Deflate

  # Use SolidCache
  config.cache_store = :solid_cache_store

  # Active Job queue adapter
  config.active_job.queue_adapter = :solid_queue

  # Logging
  config.log_level = :info
  config.log_tags = [:request_id]
end
```

### Resource Limits

```yaml
# config/deploy.yml
env:
  clear:
    WEB_CONCURRENCY: 3          # Number of Puma workers
    RAILS_MAX_THREADS: 5        # Threads per worker
    MALLOC_ARENA_MAX: 2         # Reduce memory fragmentation
```

---

## Troubleshooting

### Common Deployment Issues

```bash
# Container not starting
kamal app logs -f
kamal app containers

# Check server resources
kamal app exec "free -h"
kamal app exec "df -h"

# Database connection issues
kamal app exec "bin/rails db:version"
kamal app exec "bin/rails console"

# Restart services
kamal app restart
kamal traefik restart

# Complete cleanup and redeploy
kamal app remove
kamal deploy
```

### Debug Mode

```bash
# Enable verbose logging
kamal deploy --verbose

# SSH into container
kamal app exec --interactive bash

# Check environment variables
kamal app exec "env | grep RAILS"
```
