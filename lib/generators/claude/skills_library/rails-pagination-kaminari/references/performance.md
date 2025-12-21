# Performance Optimization for Kaminari Pagination

Strategies and best practices for optimizing pagination performance in Rails applications.

## The COUNT Query Problem

By default, Kaminari executes two queries:
1. The main SELECT query to fetch records
2. A COUNT query to get total records

For large tables, the COUNT query can be expensive.

```sql
-- Main query
SELECT * FROM posts ORDER BY created_at LIMIT 25 OFFSET 0;

-- Count query (expensive on large tables)
SELECT COUNT(*) FROM posts;
```

## Skip COUNT with without_count

```ruby
# Controller
def index
  @posts = Post.order(:created_at).page(params[:page]).without_count
end

# View - limited helpers available
<%= link_to_prev_page @posts, 'Previous' %>
<span>Page <%= @posts.current_page %></span>
<%= link_to_next_page @posts, 'Next' %>

# These won't work with without_count:
# - total_pages
# - total_count
# - numbered page links
```

## Conditional COUNT Query

Only run COUNT on first page or when explicitly requested:

```ruby
# app/controllers/posts_controller.rb
def index
  @posts = Post.order(:created_at).page(params[:page])

  # Skip count after first page
  @posts = @posts.without_count unless first_page?
end

private

def first_page?
  params[:page].blank? || params[:page].to_i <= 1
end
```

## Caching Total Count

Cache the count query result:

```ruby
# app/models/post.rb
class Post < ApplicationRecord
  def self.cached_total_count
    Rails.cache.fetch(['Post', 'total_count'], expires_in: 5.minutes) do
      count
    end
  end
end

# app/controllers/posts_controller.rb
def index
  @posts = Post.order(:created_at).page(params[:page]).without_count
  @total_count = Post.cached_total_count
  @total_pages = (@total_count.to_f / Post.default_per_page).ceil
end

# View
<div class="pagination-info">
  Page <%= @posts.current_page %> of approximately <%= @total_pages %>
</div>
```

## Counter Cache for Associations

Use counter caches to avoid counting associated records:

```ruby
# Migration
class AddPostsCountToCategories < ActiveRecord::Migration[7.0]
  def change
    add_column :categories, :posts_count, :integer, default: 0, null: false

    # Populate existing counts
    reversible do |dir|
      dir.up do
        Category.find_each do |category|
          Category.reset_counters(category.id, :posts)
        end
      end
    end
  end
end

# Model
class Post < ApplicationRecord
  belongs_to :category, counter_cache: true
end

# Controller - use counter cache instead of count
def index
  @category = Category.find(params[:category_id])
  @posts = @category.posts.page(params[:page])
  @total_count = @category.posts_count  # Fast! No COUNT query
end
```

## Database Indexes

Add indexes for paginated queries:

```ruby
# Migration
class AddIndexesToPosts < ActiveRecord::Migration[7.0]
  def change
    # For ORDER BY created_at
    add_index :posts, :created_at

    # For filtered pagination
    add_index :posts, [:category_id, :created_at]
    add_index :posts, [:published, :created_at]

    # Composite index for common queries
    add_index :posts, [:user_id, :status, :created_at]
  end
end
```

## Eager Loading (N+1 Prevention)

```ruby
# Bad - N+1 queries
def index
  @posts = Post.page(params[:page])
end

# View triggers N+1
<% @posts.each do |post| %>
  <%= post.user.name %>        # Query for each post!
  <%= post.comments.count %>   # Query for each post!
<% end %>

# Good - eager loading
def index
  @posts = Post.includes(:user, :comments)
               .page(params[:page])
end

# Multiple associations
@posts = Post.includes(:user, :category, comments: :user)
             .page(params[:page])

# Nested associations
@posts = Post.includes(comments: [:user, :likes])
             .page(params[:page])
```

## Select Only Needed Columns

```ruby
# Bad - loads all columns
@posts = Post.page(params[:page])

# Good - only load needed columns
@posts = Post.select(:id, :title, :created_at, :user_id)
             .page(params[:page])

# Even better with pluck for simple lists
@post_titles = Post.order(:created_at)
                   .page(params[:page])
                   .pluck(:id, :title)
```

## Pagination with Scopes

Use scopes to avoid repeated query building:

```ruby
# app/models/post.rb
class Post < ApplicationRecord
  scope :recent, -> { order(created_at: :desc) }
  scope :published, -> { where(published: true) }
  scope :by_category, ->(category_id) { where(category_id: category_id) if category_id.present? }
  scope :paginated, ->(page, per_page = 25) { page(page).per(per_page) }

  # Optimized scope with eager loading
  scope :with_associations, -> { includes(:user, :category) }
end

# Controller
def index
  @posts = Post.published
               .by_category(params[:category_id])
               .with_associations
               .recent
               .paginated(params[:page], 20)
end
```

## Cursor-Based Pagination

For large datasets or real-time feeds, use cursor-based pagination:

```ruby
# app/controllers/posts_controller.rb
def index
  @posts = fetch_posts_by_cursor
end

private

def fetch_posts_by_cursor
  posts = Post.order(id: :desc)

  if params[:after_id]
    posts = posts.where('id < ?', params[:after_id])
  end

  posts.limit(20)
end

# View
<% if @posts.any? %>
  <%= render @posts %>
  <%= link_to 'Load More', posts_path(after_id: @posts.last.id),
      class: 'load-more' %>
<% end %>
```

Benefits of cursor pagination:
- No COUNT query needed
- Consistent results even when data changes
- Better performance on large offsets
- Works well with infinite scroll

## Fragment Caching

Cache rendered pagination:

```ruby
# View
<% cache ["posts-index", @posts.current_page, @posts.updated_at.to_i] do %>
  <%= render @posts %>
<% end %>

<%= paginate @posts %>

# Russian Doll Caching
<% cache ["posts-index", @posts.current_page] do %>
  <% @posts.each do |post| %>
    <% cache post do %>
      <%= render post %>
    <% end %>
  <% end %>
<% end %>
```

## Query Result Caching

```ruby
# app/controllers/posts_controller.rb
def index
  cache_key = ['posts-page', params[:page], params[:category_id]].compact.join('-')

  @posts = Rails.cache.fetch(cache_key, expires_in: 5.minutes) do
    Post.published
        .by_category(params[:category_id])
        .includes(:user)
        .page(params[:page])
        .to_a  # Convert to array to cache results
  end
end
```

## Approximate COUNT for Large Tables

For very large tables, use approximate counts:

```ruby
# PostgreSQL
def approximate_count
  result = ActiveRecord::Base.connection.execute(
    "SELECT reltuples::bigint AS estimate FROM pg_class WHERE relname = 'posts'"
  )
  result[0]['estimate'].to_i
end

# Use in controller
def index
  @posts = Post.page(params[:page]).without_count
  @approximate_total = Post.approximate_count
  @approximate_pages = (@approximate_total.to_f / Post.default_per_page).ceil
end
```

## Partial Pagination

Only paginate when necessary:

```ruby
# app/controllers/posts_controller.rb
def index
  @posts = Post.order(:created_at)

  # Only paginate if there are many records
  if @posts.count > 50
    @posts = @posts.page(params[:page])
    @use_pagination = true
  end
end

# View
<%= render @posts %>
<%= paginate @posts if @use_pagination %>
```

## Database-Specific Optimizations

### PostgreSQL

```ruby
# Use DISTINCT ON for unique pagination
@posts = Post.select('DISTINCT ON (posts.user_id) posts.*')
             .order('posts.user_id, posts.created_at DESC')
             .page(params[:page])

# Use materialized views for complex queries
# db/migrate/xxx_create_popular_posts_view.rb
execute <<-SQL
  CREATE MATERIALIZED VIEW popular_posts AS
  SELECT posts.*, COUNT(likes.id) as likes_count
  FROM posts
  LEFT JOIN likes ON likes.post_id = posts.id
  GROUP BY posts.id
  ORDER BY likes_count DESC
SQL

# Refresh materialized view periodically
PopularPost.connection.execute('REFRESH MATERIALIZED VIEW popular_posts')
```

### MySQL

```ruby
# Use SQL_CALC_FOUND_ROWS (MySQL only)
class Post < ApplicationRecord
  def self.paginate_with_total(page, per_page = 25)
    offset = (page - 1) * per_page

    posts = connection.select_all(
      "SELECT SQL_CALC_FOUND_ROWS * FROM posts LIMIT #{per_page} OFFSET #{offset}"
    ).to_a

    total = connection.select_value('SELECT FOUND_ROWS()')

    Kaminari.paginate_array(posts, total_count: total).page(page).per(per_page)
  end
end
```

## Monitoring Performance

### Query Analysis

```ruby
# development.rb
config.after_initialize do
  ActiveSupport::Notifications.subscribe('sql.active_record') do |_, start, finish, _, details|
    duration = ((finish - start) * 1000).round(2)
    if duration > 100 # Log slow queries
      Rails.logger.warn "SLOW QUERY (#{duration}ms): #{details[:sql]}"
    end
  end
end
```

### Bullet Gem

```ruby
# Gemfile
group :development do
  gem 'bullet'
end

# config/environments/development.rb
config.after_initialize do
  Bullet.enable = true
  Bullet.alert = true
  Bullet.bullet_logger = true
  Bullet.console = true
  Bullet.rails_logger = true
end
```

### Benchmark Pagination

```ruby
# Controller
def index
  time = Benchmark.measure do
    @posts = Post.includes(:user, :category)
                 .order(:created_at)
                 .page(params[:page])
  end

  Rails.logger.info "Pagination took: #{time.real} seconds"
end
```

## Best Practices Summary

1. **Use indexes**: Add indexes for ORDER BY and WHERE clauses
2. **Eager load associations**: Use `includes` to prevent N+1 queries
3. **Skip COUNT when possible**: Use `without_count` for large datasets
4. **Cache counts**: Cache expensive COUNT queries
5. **Use counter caches**: For association counts
6. **Select only needed columns**: Reduce data transfer
7. **Consider cursor pagination**: For real-time feeds and large datasets
8. **Fragment cache**: Cache rendered pagination results
9. **Monitor query performance**: Use Bullet and query logs
10. **Test with production data**: Pagination performance issues often only appear at scale

## Performance Checklist

Before deploying pagination:

- [ ] Added indexes for ORDER BY columns
- [ ] Eager loaded all associations used in views
- [ ] Considered using `without_count` for large tables
- [ ] Tested with production-sized dataset
- [ ] Verified no N+1 queries with Bullet
- [ ] Measured query execution time
- [ ] Implemented caching strategy if needed
- [ ] Set reasonable `max_per_page` limit
- [ ] Tested pagination edge cases (first, last, empty)
- [ ] Verified mobile/responsive performance

## Measuring Impact

```ruby
# Before optimization
User.page(10).per(25)
# => 2 queries: SELECT (0.5ms), COUNT (150ms) - SLOW!

# After adding index
add_index :users, :created_at

User.order(:created_at).page(10).per(25)
# => 2 queries: SELECT (0.5ms), COUNT (0.8ms) - FAST!

# After using without_count
User.order(:created_at).page(10).per(25).without_count
# => 1 query: SELECT (0.5ms) - FASTEST!
```

## When to Optimize

Optimize pagination when:
- Tables have > 10,000 records
- COUNT queries take > 100ms
- Users report slow page loads
- Database CPU usage is high
- You're hitting query timeouts

Start simple, measure, then optimize based on real performance data.
