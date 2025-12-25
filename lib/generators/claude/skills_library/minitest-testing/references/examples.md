## Minitest Testing Examples

Complete code examples and patterns for Rails testing with Minitest.

---

## Fixtures

### Basic Fixture Structure

```yaml
# test/fixtures/users.yml
alice:
  email: alice@example.com
  name: Alice Smith
  role: admin
  created_at: <%= 30.days.ago %>

bob:
  email: bob@example.com
  name: Bob Jones
  role: member
  created_at: <%= 7.days.ago %>
```

### Fixtures with Associations

```yaml
# test/fixtures/articles.yml
published:
  user: alice  # references users(:alice)
  title: Published Article
  body: This article is live
  status: published
  published_at: <%= 1.day.ago %>

draft:
  user: bob
  title: Draft Article
  body: Work in progress
  status: draft
  published_at: nil

# test/fixtures/comments.yml
first_comment:
  article: published  # references articles(:published)
  user: bob
  body: Great article!
  created_at: <%= 1.hour.ago %>
```

### ERB in Fixtures

```yaml
# test/fixtures/posts.yml
<% 10.times do |i| %>
post_<%= i %>:
  title: "Post <%= i %>"
  body: "Content for post <%= i %>"
  published_at: <%= i.days.ago %>
<% end %>
```

---

## Model Testing

### Testing Validations

```ruby
# test/models/article_test.rb
class ArticleTest < ActiveSupport::TestCase
  test "validates presence of title" do
    article = Article.new(body: "Content")
    assert_not article.valid?
    assert_includes article.errors[:title], "can't be blank"
  end

  test "validates title length" do
    article = Article.new(title: "a" * 256, body: "Content")
    assert_not article.valid?
    assert_includes article.errors[:title], "is too long"
  end

  test "validates uniqueness of title" do
    existing = articles(:published)
    duplicate = Article.new(title: existing.title, body: "Different body")

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:title], "has already been taken"
  end

  test "valid with all required attributes" do
    article = Article.new(
      title: "Valid Title",
      body: "Valid content",
      user: users(:alice)
    )
    assert article.valid?
  end
end
```

### Testing Associations

```ruby
class ArticleTest < ActiveSupport::TestCase
  test "belongs to user" do
    article = articles(:published)
    assert_instance_of User, article.user
    assert_equal users(:alice), article.user
  end

  test "has many comments" do
    article = articles(:published)
    assert_respond_to article, :comments
    assert article.comments.is_a?(ActiveRecord::Associations::CollectionProxy)
  end

  test "destroys dependent comments when destroyed" do
    article = articles(:published)
    comment_ids = article.comments.pluck(:id)

    assert_difference "Comment.count", -article.comments.count do
      article.destroy
    end

    comment_ids.each do |id|
      assert_nil Comment.find_by(id: id)
    end
  end
end
```

### Testing Scopes

```ruby
class ArticleTest < ActiveSupport::TestCase
  test ".published returns only published articles" do
    published = articles(:published)
    draft = articles(:draft)

    results = Article.published

    assert_includes results, published
    assert_not_includes results, draft
  end

  test ".recent orders by created_at desc" do
    articles = Article.recent.to_a
    assert_equal articles, articles.sort_by(&:created_at).reverse
  end

  test ".by_user filters articles by user" do
    alice = users(:alice)
    alice_articles = Article.by_user(alice)

    alice_articles.each do |article|
      assert_equal alice, article.user
    end
  end
end
```

### Testing Callbacks

```ruby
class ArticleTest < ActiveSupport::TestCase
  test "sets published_at when status changes to published" do
    article = articles(:draft)
    assert_nil article.published_at

    article.update(status: :published)

    assert_not_nil article.published_at
    assert_in_delta Time.current, article.published_at, 2.seconds
  end

  test "generates slug before validation" do
    article = Article.new(title: "Hello World", body: "Content")
    article.valid?

    assert_equal "hello-world", article.slug
  end

  test "sends notification email after create" do
    assert_difference "ActionMailer::Base.deliveries.size", 1 do
      Article.create!(
        title: "New Article",
        body: "Content",
        user: users(:alice)
      )
    end
  end
end
```

### Testing Enums

```ruby
class ArticleTest < ActiveSupport::TestCase
  test "defines status enum correctly" do
    article = Article.new

    assert_respond_to article, :status
    assert_respond_to article, :draft?
    assert_respond_to article, :published?
  end

  test "default status is draft" do
    article = Article.new
    assert article.draft?
  end

  test "can transition status" do
    article = articles(:draft)
    assert article.draft?

    article.published!
    assert article.published?
  end
end
```

### Testing Custom Methods

```ruby
class ArticleTest < ActiveSupport::TestCase
  test "#excerpt returns first 100 characters" do
    long_body = "a" * 200
    article = Article.new(body: long_body)

    excerpt = article.excerpt

    assert_equal 100, excerpt.length
    assert excerpt.ends_with?("...")
  end

  test "#reading_time calculates minutes" do
    words = ("word " * 500).strip  # 500 words
    article = Article.new(body: words)

    # Assuming 200 words per minute
    assert_equal 3, article.reading_time  # 500/200 = 2.5 rounded up
  end

  test "#publish! transitions to published and sets timestamp" do
    article = articles(:draft)

    article.publish!

    assert article.published?
    assert_not_nil article.published_at
  end
end
```

---

## Controller Testing

### Testing Index Action

```ruby
# test/controllers/articles_controller_test.rb
class ArticlesControllerTest < ActionDispatch::IntegrationTest
  test "GET index returns success" do
    get articles_path
    assert_response :success
  end

  test "GET index assigns @articles" do
    get articles_path
    assert_not_nil assigns(:articles)
  end

  test "GET index only shows published articles" do
    get articles_path

    assert_select "article", count: Article.published.count
  end
end
```

### Testing Show Action

```ruby
class ArticlesControllerTest < ActionDispatch::IntegrationTest
  test "GET show displays article" do
    article = articles(:published)
    get article_path(article)

    assert_response :success
    assert_select "h1", text: article.title
  end

  test "GET show returns 404 for non-existent article" do
    assert_raises ActiveRecord::RecordNotFound do
      get article_path(id: "nonexistent")
    end
  end
end
```

### Testing Create Action

```ruby
class ArticlesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:alice)
    sign_in_as(@user)
  end

  test "POST create with valid params creates article" do
    assert_difference("Article.count", 1) do
      post articles_path, params: {
        article: {
          title: "New Article",
          body: "Article content here"
        }
      }
    end

    assert_redirected_to article_path(Article.last)
    follow_redirect!
    assert_select ".notice", text: "Article was successfully created"
  end

  test "POST create with invalid params renders new" do
    assert_no_difference("Article.count") do
      post articles_path, params: {
        article: { title: "", body: "" }
      }
    end

    assert_response :unprocessable_entity
  end

  test "POST create assigns current user as author" do
    post articles_path, params: {
      article: { title: "Test", body: "Content" }
    }

    assert_equal @user, Article.last.user
  end
end
```

### Testing Update Action

```ruby
class ArticlesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @article = articles(:draft)
    @user = @article.user
    sign_in_as(@user)
  end

  test "PATCH update with valid params updates article" do
    patch article_path(@article), params: {
      article: { title: "Updated Title" }
    }

    assert_redirected_to article_path(@article)
    @article.reload
    assert_equal "Updated Title", @article.title
  end

  test "PATCH update with invalid params renders edit" do
    patch article_path(@article), params: {
      article: { title: "" }
    }

    assert_response :unprocessable_entity
    @article.reload
    assert_not_equal "", @article.title
  end
end
```

### Testing Destroy Action

```ruby
class ArticlesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @article = articles(:draft)
    sign_in_as(@article.user)
  end

  test "DELETE destroy removes article" do
    assert_difference("Article.count", -1) do
      delete article_path(@article)
    end

    assert_redirected_to articles_path
  end
end
```

### Testing Authentication

```ruby
class ArticlesControllerTest < ActionDispatch::IntegrationTest
  test "GET new redirects to login when not authenticated" do
    get new_article_path
    assert_redirected_to login_path
  end

  test "POST create requires authentication" do
    post articles_path, params: {
      article: { title: "Test", body: "Content" }
    }

    assert_redirected_to login_path
  end
end
```

### Testing Authorization

```ruby
class ArticlesControllerTest < ActionDispatch::IntegrationTest
  test "DELETE destroy only allowed by article owner" do
    article = articles(:published)  # owned by alice
    other_user = users(:bob)
    sign_in_as(other_user)

    assert_no_difference("Article.count") do
      delete article_path(article)
    end

    assert_response :forbidden
  end

  test "admin can delete any article" do
    article = articles(:published)
    admin = users(:alice)  # alice is admin
    sign_in_as(admin)

    assert_difference("Article.count", -1) do
      delete article_path(article)
    end
  end
end
```

---

## System Testing

### Basic System Test

```ruby
# test/system/article_creation_test.rb
class ArticleCreationTest < ApplicationSystemTestCase
  test "user creates new article successfully" do
    visit root_path
    click_on "Sign In"

    fill_in "Email", with: "alice@example.com"
    fill_in "Password", with: "password"
    click_on "Log In"

    click_on "New Article"

    fill_in "Title", with: "My Test Article"
    fill_in "Body", with: "This is the article content"
    select "Published", from: "Status"

    click_on "Create Article"

    assert_text "Article was successfully created"
    assert_text "My Test Article"
  end
end
```

### Testing Form Validation

```ruby
class ArticleCreationTest < ApplicationSystemTestCase
  test "shows validation errors for invalid article" do
    sign_in_as users(:alice)
    visit new_article_path

    click_on "Create Article"

    assert_text "Title can't be blank"
    assert_text "Body can't be blank"
  end
end
```

### Testing JavaScript Behavior

```ruby
class ArticleInteractionTest < ApplicationSystemTestCase
  test "toggles article favorite with JavaScript" do
    sign_in_as users(:alice)
    article = articles(:published)
    visit article_path(article)

    # Click favorite button
    find("[data-test-id='favorite-button']").click

    # Wait for JS to complete
    assert_selector "[data-test-id='favorite-button'][aria-pressed='true']"
  end
end
```

### Testing Turbo Frames

```ruby
class ArticleEditingTest < ApplicationSystemTestCase
  test "edits article inline with Turbo Frame" do
    sign_in_as users(:alice)
    article = articles(:draft)
    visit article_path(article)

    within "#article_#{article.id}" do
      click_on "Edit"
      fill_in "Title", with: "Updated Title"
      click_on "Update Article"

      # Turbo Frame replaces content without full page reload
      assert_text "Updated Title"
    end

    # Page URL hasn't changed
    assert_current_path article_path(article)
  end
end
```

### Testing Turbo Streams

```ruby
class CommentCreationTest < ApplicationSystemTestCase
  test "adds comment dynamically with Turbo Stream" do
    sign_in_as users(:alice)
    article = articles(:published)
    visit article_path(article)

    initial_count = article.comments.count

    fill_in "Comment", with: "Great article!"
    click_on "Post Comment"

    # Turbo Stream appends new comment without reload
    assert_selector ".comment", count: initial_count + 1
    assert_text "Great article!"
  end
end
```

### Capybara Selectors

```ruby
class SearchTest < ApplicationSystemTestCase
  test "searches articles with various selectors" do
    visit articles_path

    # By CSS
    find(".search-input").fill_in with: "rails"

    # By test ID
    find("[data-test-id='search-submit']").click

    # By text
    click_on "Rails"

    # By label
    fill_in "Search", with: "ruby"

    # Within scope
    within ".search-results" do
      assert_text "Found 5 articles"
    end

    # By XPath (less preferred)
    find(:xpath, "//input[@name='q']").fill_in with: "test"
  end
end
```

### Testing Modals and Dialogs

```ruby
class ArticleDeletionTest < ApplicationSystemTestCase
  test "confirms deletion with modal" do
    sign_in_as users(:alice)
    article = articles(:draft)
    visit article_path(article)

    click_on "Delete Article"

    # Confirm in modal dialog
    within "#confirmation-modal" do
      assert_text "Are you sure?"
      click_on "Confirm"
    end

    assert_text "Article was deleted"
    assert_no_text article.title
  end
end
```

---

## Testing Background Jobs

### Testing Job Enqueuing

```ruby
# test/jobs/article_notification_job_test.rb
class ArticleNotificationJobTest < ActiveJob::TestCase
  test "enqueues job when article is published" do
    article = articles(:draft)

    assert_enqueued_with(job: ArticleNotificationJob, args: [article]) do
      article.update(status: :published)
    end
  end

  test "performs job and sends notification" do
    article = articles(:published)

    assert_emails 1 do
      ArticleNotificationJob.perform_now(article)
    end
  end

  test "retries on failure" do
    article = articles(:published)

    # Stub to raise error
    NotificationMailer.stub :article_published, -> { raise "API Error" } do
      assert_raises "API Error" do
        ArticleNotificationJob.perform_now(article)
      end
    end

    assert_enqueued_jobs 1, only: ArticleNotificationJob
  end
end
```

---

## Testing Mailers

### Testing Email Delivery

```ruby
# test/mailers/notification_mailer_test.rb
class NotificationMailerTest < ActionMailer::TestCase
  test "sends welcome email" do
    user = users(:alice)
    email = NotificationMailer.welcome_email(user)

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal [user.email], email.to
    assert_equal ["noreply@example.com"], email.from
    assert_equal "Welcome to the Blog!", email.subject
  end

  test "includes user name in email body" do
    user = users(:alice)
    email = NotificationMailer.welcome_email(user)

    assert_match user.name, email.html_part.body.to_s
    assert_match user.name, email.text_part.body.to_s
  end

  test "enqueues email for async delivery" do
    user = users(:alice)

    assert_enqueued_with(job: ActionMailer::MailDeliveryJob) do
      NotificationMailer.welcome_email(user).deliver_later
    end
  end
end
```

---

## Test Helpers

### Authentication Helper

```ruby
# test/test_helper.rb
class ActionDispatch::IntegrationTest
  def sign_in_as(user, password: "password")
    post login_path, params: {
      email: user.email,
      password: password
    }
  end

  def sign_out
    delete logout_path
  end

  def current_user
    User.find_by(id: session[:user_id]) if session[:user_id]
  end
end
```

### System Test Helpers

```ruby
# test/application_system_test_case.rb
class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome

  def sign_in_as(user)
    visit login_path
    fill_in "Email", with: user.email
    fill_in "Password", with: "password"
    click_on "Log In"
  end

  def wait_for_turbo(timeout: 2)
    if has_css?(".turbo-progress-bar", visible: true, wait: 0.25.seconds)
      has_no_css?(".turbo-progress-bar", wait: timeout)
    end
  end
end
```

### Custom Assertions

```ruby
# test/test_helper.rb
module ActiveSupport
  class TestCase
    def assert_valid(record, message = nil)
      msg = message || "Expected #{record.class} to be valid, errors: #{record.errors.full_messages.join(', ')}"
      assert record.valid?, msg
    end

    def assert_invalid(record, attribute = nil)
      assert_not record.valid?, "Expected #{record.class} to be invalid"
      if attribute
        assert_not_empty record.errors[attribute], "Expected errors on #{attribute}"
      end
    end

    def assert_enqueued_email_to(recipient, &block)
      jobs_before = enqueued_jobs.count
      block.call
      jobs_after = enqueued_jobs.count

      assert jobs_after > jobs_before, "Expected email to be enqueued"

      job = enqueued_jobs.last
      assert_equal recipient, job[:args].first["arguments"].first["to"]
    end
  end
end
```

---

## Mocking and Stubbing

### Using Minitest::Mock

```ruby
class PaymentServiceTest < ActiveSupport::TestCase
  test "processes payment through external API" do
    mock_gateway = Minitest::Mock.new
    mock_gateway.expect :charge, true, [100, "USD"]

    service = PaymentService.new(gateway: mock_gateway)
    result = service.process(amount: 100, currency: "USD")

    assert result
    mock_gateway.verify
  end
end
```

### Stubbing Methods

```ruby
class ArticleTest < ActiveSupport::TestCase
  test "publishes to social media" do
    article = articles(:published)

    article.stub :post_to_twitter, true do
      article.stub :post_to_facebook, true do
        result = article.share_on_social_media

        assert result
      end
    end
  end
end
```

### Stubbing Class Methods

```ruby
class WeatherServiceTest < ActiveSupport::TestCase
  test "fetches weather from API" do
    WeatherAPI.stub :fetch, { temp: 72, condition: "Sunny" } do
      result = WeatherService.current_weather("New York")

      assert_equal 72, result[:temp]
      assert_equal "Sunny", result[:condition]
    end
  end
end
```

---

## Parallel Testing

### Setup for Parallel Tests

```ruby
# test/test_helper.rb
class ActiveSupport::TestCase
  # Ensure tests can run in parallel
  parallelize(workers: :number_of_processors)

  # Use separate databases for parallel workers
  parallelize_setup do |worker|
    SimpleCov.command_name "#{SimpleCov.command_name}-#{worker}"
  end

  parallelize_teardown do |worker|
    SimpleCov.result
  end
end
```

### Running Parallel Tests

```bash
# Run tests in parallel
bin/rails test

# Disable parallel for debugging
PARALLEL_WORKERS=1 bin/rails test

# Specify number of workers
PARALLEL_WORKERS=4 bin/rails test
```

---

## Coverage and Reporting

### SimpleCov Setup

```ruby
# test/test_helper.rb
require "simplecov"
SimpleCov.start "rails" do
  add_filter "/test/"
  add_filter "/config/"
  add_group "Models", "app/models"
  add_group "Controllers", "app/controllers"
  add_group "Jobs", "app/jobs"
  add_group "Mailers", "app/mailers"
end

ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
```

```bash
# Run tests with coverage
COVERAGE=true bin/rails test

# View coverage report
open coverage/index.html
```
