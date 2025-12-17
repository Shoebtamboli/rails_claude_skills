# JSON Serialization Patterns

Control how your models are serialized to JSON for API responses. Choose the right serialization approach based on your needs.

## Default Rails Serialization

Rails provides basic JSON serialization out of the box:

### as_json / to_json

```ruby
# In controller
def show
  render json: @article
end

# Customize in model
class Article < ApplicationRecord
  def as_json(options = {})
    super(
      only: [:id, :title, :body, :status],
      include: {
        author: { only: [:id, :name, :email] },
        comments: { only: [:id, :body, :created_at] }
      },
      methods: [:word_count]
    )
  end

  def word_count
    body.split.size
  end
end
```

**Pros:** Built-in, no dependencies
**Cons:** Mixes presentation logic with models, not reusable

## Jbuilder (Rails Default)

Jbuilder uses view templates for JSON responses:

### Basic Usage

```ruby
# app/views/api/v1/articles/show.json.jbuilder
json.article do
  json.id @article.id
  json.title @article.title
  json.body @article.body
  json.status @article.status
  json.created_at @article.created_at

  json.author do
    json.id @article.author.id
    json.name @article.author.name
    json.email @article.author.email
  end
end
```

### Collections

```ruby
# app/views/api/v1/articles/index.json.jbuilder
json.data @articles do |article|
  json.id article.id
  json.title article.title
  json.excerpt article.body.truncate(100)
  json.author_name article.author.name
end

json.meta do
  json.current_page @articles.current_page
  json.total_pages @articles.total_pages
  json.total_count @articles.total_count
end
```

### Partials

```ruby
# app/views/api/v1/articles/_article.json.jbuilder
json.extract! article, :id, :title, :body, :status, :created_at

json.author do
  json.partial! 'api/v1/users/user', user: article.author
end

# app/views/api/v1/articles/show.json.jbuilder
json.article do
  json.partial! 'article', article: @article
end
```

**Pros:** Familiar view-based approach, good for complex nested data
**Cons:** Slower than other options, requires view files

## ActiveModelSerializers (AMS)

Class-based serializers with conventions:

### Installation

```ruby
# Gemfile
gem 'active_model_serializers', '~> 0.10.0'
```

### Basic Serializer

```ruby
# app/serializers/article_serializer.rb
class ArticleSerializer < ActiveModel::Serializer
  attributes :id, :title, :body, :status, :created_at, :word_count

  belongs_to :author
  has_many :comments

  def word_count
    object.body.split.size
  end
end

# app/serializers/author_serializer.rb
class AuthorSerializer < ActiveModel::Serializer
  attributes :id, :name, :email
end

# Controller automatically uses serializer
def show
  render json: @article  # Uses ArticleSerializer
end
```

### Conditional Attributes

```ruby
class ArticleSerializer < ActiveModel::Serializer
  attributes :id, :title, :body, :draft_notes

  def draft_notes
    object.draft_notes if object.status == 'draft'
  end

  def include_draft_notes?
    object.status == 'draft'
  end
end
```

### Custom Serializers

```ruby
# Use specific serializer
render json: @article, serializer: ArticleDetailSerializer

# Disable serializer
render json: @article, serializer: nil

# Collection with meta
render json: @articles,
       meta: { total_count: @articles.total_count },
       meta_key: 'pagination'
```

**Pros:** Convention over configuration, automatic associations
**Cons:** Slower than simpler alternatives, less active maintenance

## Blueprinter (Recommended)

Fast, declarative serialization with great performance:

### Installation

```ruby
# Gemfile
gem 'blueprinter'
```

### Basic Blueprint

```ruby
# app/blueprints/article_blueprint.rb
class ArticleBlueprint < Blueprinter::Base
  identifier :id

  fields :title, :body, :status, :created_at

  field :word_count do |article|
    article.body.split.size
  end

  association :author, blueprint: AuthorBlueprint
  association :comments, blueprint: CommentBlueprint
end

# app/blueprints/author_blueprint.rb
class AuthorBlueprint < Blueprinter::Base
  identifier :id
  fields :name, :email
end

# In controller
def show
  render json: ArticleBlueprint.render(@article)
end

def index
  render json: ArticleBlueprint.render(@articles)
end
```

### Views (Different Representations)

```ruby
class ArticleBlueprint < Blueprinter::Base
  identifier :id

  # Default view
  fields :title, :status, :created_at

  # Extended view with more fields
  view :extended do
    fields :body, :updated_at
    association :author, blueprint: AuthorBlueprint
  end

  # Summary view with minimal fields
  view :summary do
    field :title
    field :excerpt do |article|
      article.body.truncate(100)
    end
  end
end

# Usage
ArticleBlueprint.render(@article)                      # Default view
ArticleBlueprint.render(@article, view: :extended)     # Extended view
ArticleBlueprint.render(@articles, view: :summary)     # Summary for list
```

### Conditional Fields

```ruby
class ArticleBlueprint < Blueprinter::Base
  fields :id, :title, :body

  field :draft_notes, if: ->(article, _options) { article.status == 'draft' }

  field :edit_url, if: ->(article, options) {
    options[:current_user]&.can_edit?(article)
  }
end

# Usage
ArticleBlueprint.render(@article, current_user: current_user)
```

### Meta and Root

```ruby
# With meta
render json: ArticleBlueprint.render(@articles, meta: {
  total_count: @articles.total_count,
  current_page: @articles.current_page
})

# Output:
# {
#   "data": [...articles...],
#   "meta": { "total_count": 42, "current_page": 1 }
# }

# Custom root
ArticleBlueprint.render(@articles, root: :articles)
# { "articles": [...] }
```

**Pros:** Fast (5-10x faster than AMS), simple, flexible views
**Cons:** Less magic, more explicit

## JSONAPI::Serializer (formerly fast_jsonapi)

JSON:API specification compliant serialization:

### Installation

```ruby
# Gemfile
gem 'jsonapi-serializer'
```

### Basic Serializer

```ruby
# app/serializers/article_serializer.rb
class ArticleSerializer
  include JSONAPI::Serializer

  attributes :title, :body, :status, :created_at

  attribute :word_count do |article|
    article.body.split.size
  end

  belongs_to :author
  has_many :comments
end

# In controller
def show
  render json: ArticleSerializer.new(@article).serializable_hash
end
```

### JSON:API Response Format

```json
{
  "data": {
    "id": "1",
    "type": "article",
    "attributes": {
      "title": "Rails API Guide",
      "body": "Content here...",
      "status": "published",
      "created_at": "2025-01-15T10:00:00Z"
    },
    "relationships": {
      "author": {
        "data": { "id": "5", "type": "user" }
      }
    }
  },
  "included": [
    {
      "id": "5",
      "type": "user",
      "attributes": {
        "name": "John Doe"
      }
    }
  ]
}
```

### With Includes

```ruby
# Include related resources
options = { include: [:author, :comments] }
ArticleSerializer.new(@article, options).serializable_hash

# Conditional includes based on params
def show
  options = {}
  options[:include] = params[:include].split(',') if params[:include].present?

  render json: ArticleSerializer.new(@article, options).serializable_hash
end
```

**Pros:** JSON:API compliant, fast, handles includes well
**Cons:** Opinionated format, more verbose responses

## Comparison Table

| Gem | Speed | Flexibility | Learning Curve | Use Case |
|-----|-------|-------------|----------------|----------|
| **as_json** | Fast | Low | Easy | Simple APIs, prototypes |
| **Jbuilder** | Slow | High | Easy | Complex nested data, familiar views |
| **AMS** | Slow | Medium | Medium | Rails conventions, associations |
| **Blueprinter** | Very Fast | High | Easy | Production APIs, performance-critical |
| **JSONAPI::Serializer** | Fast | Medium | Medium | JSON:API clients, standardized APIs |

## Recommendation by Project Size

### Small Projects / Prototypes
Use Rails default `as_json` or Jbuilder:
```ruby
render json: @article.as_json(only: [:id, :title], include: :author)
```

### Medium Projects
Use Blueprinter for simplicity and speed:
```ruby
ArticleBlueprint.render(@article, view: :detailed)
```

### Large Projects / JSON:API Clients
Use JSONAPI::Serializer for spec compliance:
```ruby
ArticleSerializer.new(@article, include: [:author]).serializable_hash
```

## Performance Tips

1. **Select Only Needed Fields**
   ```ruby
   # Bad - loads all columns
   @articles = Article.all

   # Good - only loads needed columns
   @articles = Article.select(:id, :title, :body, :created_at)
   ```

2. **Eager Load Associations**
   ```ruby
   # Bad - N+1 queries
   @articles = Article.all

   # Good - single query
   @articles = Article.includes(:author, :comments)
   ```

3. **Use Caching**
   ```ruby
   # In serializer/blueprint
   def show
     json = Rails.cache.fetch([@article, 'v1']) do
       ArticleBlueprint.render(@article)
     end
     render json: json
   end
   ```

4. **Paginate Collections**
   ```ruby
   @articles = Article.page(params[:page]).per(20)
   ```

## Testing Serializers

```ruby
# spec/blueprints/article_blueprint_spec.rb
RSpec.describe ArticleBlueprint do
  let(:article) { create(:article, title: 'Test') }

  it 'serializes basic fields' do
    result = JSON.parse(ArticleBlueprint.render(article))

    expect(result['id']).to eq(article.id)
    expect(result['title']).to eq('Test')
    expect(result).to have_key('created_at')
  end

  it 'includes author in extended view' do
    result = JSON.parse(ArticleBlueprint.render(article, view: :extended))

    expect(result).to have_key('author')
    expect(result['author']['name']).to eq(article.author.name)
  end
end
```
