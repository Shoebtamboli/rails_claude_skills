# API Pagination with Kaminari

Best practices and patterns for implementing pagination in JSON APIs using Kaminari.

## REST API Pagination

### Basic JSON Response

```ruby
# app/controllers/api/v1/posts_controller.rb
module Api
  module V1
    class PostsController < ApplicationController
      def index
        @posts = Post.page(params[:page]).per(per_page)

        render json: {
          data: @posts.map { |post| PostSerializer.new(post).as_json },
          pagination: pagination_metadata(@posts)
        }
      end

      private

      def per_page
        [(params[:per_page] || 20).to_i, 100].min  # Max 100 per page
      end

      def pagination_metadata(collection)
        {
          current_page: collection.current_page,
          next_page: collection.next_page,
          prev_page: collection.prev_page,
          total_pages: collection.total_pages,
          total_count: collection.total_count,
          per_page: collection.limit_value
        }
      end
    end
  end
end
```

### Response Example

```json
{
  "data": [
    {
      "id": 1,
      "title": "First Post",
      "body": "Content here..."
    }
  ],
  "pagination": {
    "current_page": 1,
    "next_page": 2,
    "prev_page": null,
    "total_pages": 10,
    "total_count": 245,
    "per_page": 25
  }
}
```

## Pagination Concern

Create a reusable concern for API pagination:

```ruby
# app/controllers/concerns/api_paginatable.rb
module ApiPaginatable
  extend ActiveSupport::Concern

  included do
    helper_method :pagination_meta, :pagination_links
  end

  def paginate(collection)
    collection
      .page(params[:page] || 1)
      .per(per_page_param)
  end

  def pagination_meta(collection)
    {
      current_page: collection.current_page,
      next_page: collection.next_page,
      prev_page: collection.prev_page,
      total_pages: collection.total_pages,
      total_count: collection.total_count,
      per_page: collection.limit_value
    }
  end

  def pagination_links(collection)
    base_url = request.base_url + request.path

    {
      self: build_link_url(base_url, collection.current_page),
      first: build_link_url(base_url, 1),
      prev: collection.prev_page ? build_link_url(base_url, collection.prev_page) : nil,
      next: collection.next_page ? build_link_url(base_url, collection.next_page) : nil,
      last: build_link_url(base_url, collection.total_pages)
    }
  end

  private

  def per_page_param
    per = params[:per_page].to_i
    per = default_per_page if per <= 0
    [per, max_per_page].min
  end

  def default_per_page
    20
  end

  def max_per_page
    100
  end

  def build_link_url(base_url, page)
    query_params = request.query_parameters.merge(page: page, per_page: per_page_param)
    "#{base_url}?#{query_params.to_query}"
  end
end
```

### Using the Concern

```ruby
# app/controllers/api/v1/posts_controller.rb
module Api
  module V1
    class PostsController < ApplicationController
      include ApiPaginatable

      def index
        @posts = paginate(Post.order(:created_at))

        render json: {
          data: @posts,
          meta: pagination_meta(@posts),
          links: pagination_links(@posts)
        }
      end
    end
  end
end
```

## Link Header Pagination (GitHub Style)

```ruby
# app/controllers/concerns/link_header_pagination.rb
module LinkHeaderPagination
  extend ActiveSupport::Concern

  included do
    after_action :set_pagination_headers, only: [:index]
  end

  def set_pagination_headers
    return unless @paginated_collection

    links = []
    links << build_link_header('first', 1)
    links << build_link_header('prev', @paginated_collection.prev_page) if @paginated_collection.prev_page
    links << build_link_header('next', @paginated_collection.next_page) if @paginated_collection.next_page
    links << build_link_header('last', @paginated_collection.total_pages)

    response.headers['Link'] = links.join(', ')
    response.headers['X-Total-Count'] = @paginated_collection.total_count.to_s
    response.headers['X-Total-Pages'] = @paginated_collection.total_pages.to_s
    response.headers['X-Per-Page'] = @paginated_collection.limit_value.to_s
    response.headers['X-Page'] = @paginated_collection.current_page.to_s
  end

  private

  def build_link_header(rel, page)
    url = url_for(request.query_parameters.merge(page: page, only_path: false))
    %(<#{url}>; rel="#{rel}")
  end
end

# app/controllers/api/v1/posts_controller.rb
module Api
  module V1
    class PostsController < ApplicationController
      include LinkHeaderPagination

      def index
        @paginated_collection = Post.page(params[:page]).per(20)
        render json: @paginated_collection
      end
    end
  end
end
```

### Example Response Headers

```
Link: <http://api.example.com/posts?page=1>; rel="first",
      <http://api.example.com/posts?page=2>; rel="prev",
      <http://api.example.com/posts?page=4>; rel="next",
      <http://api.example.com/posts?page=10>; rel="last"
X-Total-Count: 245
X-Total-Pages: 10
X-Per-Page: 25
X-Page: 3
```

## Cursor-Based Pagination

For real-time feeds and large datasets:

```ruby
# app/controllers/api/v1/posts_controller.rb
module Api
  module V1
    class PostsController < ApplicationController
      def index
        @posts = fetch_posts

        render json: {
          data: @posts,
          meta: cursor_meta(@posts)
        }
      end

      private

      def fetch_posts
        posts = Post.order(id: :desc)
        posts = posts.where('id < ?', params[:before]) if params[:before]
        posts = posts.where('id > ?', params[:after]) if params[:after]
        posts.limit(per_page + 1)
      end

      def cursor_meta(posts)
        has_more = posts.size > per_page
        posts = posts.first(per_page) if has_more

        {
          before: posts.first&.id,
          after: posts.last&.id,
          has_more: has_more
        }
      end

      def per_page
        20
      end
    end
  end
end
```

## JSON:API Specification

Following JSON:API pagination spec:

```ruby
# app/controllers/api/v1/posts_controller.rb
module Api
  module V1
    class PostsController < ApplicationController
      def index
        @posts = Post.page(params[:page][:number]).per(params[:page][:size] || 20)

        render json: {
          data: @posts.map { |post| PostSerializer.new(post).as_json },
          links: jsonapi_pagination_links(@posts),
          meta: {
            total: @posts.total_count
          }
        }
      end

      private

      def jsonapi_pagination_links(collection)
        base_url = request.base_url + request.path

        {
          self: build_jsonapi_url(base_url, collection.current_page),
          first: build_jsonapi_url(base_url, 1),
          prev: collection.prev_page ? build_jsonapi_url(base_url, collection.prev_page) : nil,
          next: collection.next_page ? build_jsonapi_url(base_url, collection.next_page) : nil,
          last: build_jsonapi_url(base_url, collection.total_pages)
        }
      end

      def build_jsonapi_url(base_url, page_number)
        "#{base_url}?page[number]=#{page_number}&page[size]=#{params.dig(:page, :size) || 20}"
      end
    end
  end
end
```

## GraphQL Pagination

```ruby
# app/graphql/types/query_type.rb
module Types
  class QueryType < Types::BaseObject
    field :posts, Types::PostType.connection_type, null: false do
      argument :page, Integer, required: false, default_value: 1
      argument :per_page, Integer, required: false, default_value: 20
    end

    def posts(page:, per_page:)
      Post.page(page).per([per_page, 100].min)
    end
  end
end
```

## Performance Optimization for APIs

### Without Count for Large Datasets

```ruby
# app/controllers/api/v1/posts_controller.rb
def index
  @posts = Post.page(params[:page]).per(20).without_count

  render json: {
    data: @posts,
    pagination: {
      current_page: @posts.current_page,
      next_page: @posts.next_page,
      prev_page: @posts.prev_page,
      per_page: @posts.limit_value
      # total_pages and total_count not available
    }
  }
end
```

### Conditional Count Query

```ruby
# Only run count query on first page
def index
  @posts = Post.page(params[:page]).per(20)
  @posts = @posts.without_count unless params[:page].to_i == 1

  meta = {
    current_page: @posts.current_page,
    per_page: @posts.limit_value
  }

  # Only include total counts on first page
  if params[:page].to_i == 1
    meta[:total_pages] = @posts.total_pages
    meta[:total_count] = @posts.total_count
  end

  render json: {
    data: @posts,
    pagination: meta
  }
end
```

### Caching Total Count

```ruby
# app/controllers/api/v1/posts_controller.rb
def index
  @posts = Post.page(params[:page]).per(20)

  # Cache the total count
  total_count = Rails.cache.fetch(['posts', 'total_count'], expires_in: 5.minutes) do
    Post.count
  end

  render json: {
    data: @posts,
    pagination: {
      current_page: @posts.current_page,
      total_count: total_count,
      total_pages: (total_count.to_f / 20).ceil
    }
  }
end
```

## Filtering with Pagination

```ruby
# app/controllers/api/v1/posts_controller.rb
def index
  @posts = Post.all
  @posts = apply_filters(@posts)
  @posts = @posts.page(params[:page]).per(per_page)

  render json: {
    data: @posts,
    pagination: pagination_meta(@posts),
    links: pagination_links_with_filters(@posts)
  }
end

private

def apply_filters(scope)
  scope = scope.where(category: params[:category]) if params[:category]
  scope = scope.where(status: params[:status]) if params[:status]
  scope = scope.where('created_at > ?', params[:since]) if params[:since]
  scope
end

def pagination_links_with_filters(collection)
  base_url = request.base_url + request.path
  filter_params = request.query_parameters.except(:page, :per_page)

  {
    self: build_filtered_url(base_url, collection.current_page, filter_params),
    first: build_filtered_url(base_url, 1, filter_params),
    prev: collection.prev_page ? build_filtered_url(base_url, collection.prev_page, filter_params) : nil,
    next: collection.next_page ? build_filtered_url(base_url, collection.next_page, filter_params) : nil,
    last: build_filtered_url(base_url, collection.total_pages, filter_params)
  }
end

def build_filtered_url(base_url, page, filters)
  query = filters.merge(page: page, per_page: per_page)
  "#{base_url}?#{query.to_query}"
end
```

## Testing API Pagination

```ruby
# spec/requests/api/v1/posts_spec.rb
require 'rails_helper'

RSpec.describe 'Api::V1::Posts', type: :request do
  let!(:posts) { create_list(:post, 30) }
  let(:headers) { { 'Content-Type' => 'application/json' } }

  describe 'GET /api/v1/posts' do
    it 'returns paginated posts' do
      get '/api/v1/posts', params: { page: 1, per_page: 10 }, headers: headers

      json = JSON.parse(response.body)

      expect(response).to have_http_status(:ok)
      expect(json['data'].size).to eq(10)
      expect(json['pagination']['current_page']).to eq(1)
      expect(json['pagination']['total_pages']).to eq(3)
      expect(json['pagination']['total_count']).to eq(30)
    end

    it 'returns second page' do
      get '/api/v1/posts', params: { page: 2, per_page: 10 }, headers: headers

      json = JSON.parse(response.body)

      expect(json['data'].size).to eq(10)
      expect(json['pagination']['current_page']).to eq(2)
      expect(json['pagination']['next_page']).to eq(3)
      expect(json['pagination']['prev_page']).to eq(1)
    end

    it 'returns empty array for out of range page' do
      get '/api/v1/posts', params: { page: 999 }, headers: headers

      json = JSON.parse(response.body)

      expect(json['data']).to be_empty
    end

    it 'respects per_page parameter' do
      get '/api/v1/posts', params: { per_page: 5 }, headers: headers

      json = JSON.parse(response.body)

      expect(json['data'].size).to eq(5)
      expect(json['pagination']['per_page']).to eq(5)
    end

    it 'enforces maximum per_page' do
      get '/api/v1/posts', params: { per_page: 999 }, headers: headers

      json = JSON.parse(response.body)

      expect(json['pagination']['per_page']).to eq(100)  # Max limit
    end

    it 'includes pagination links' do
      get '/api/v1/posts', params: { page: 2 }, headers: headers

      json = JSON.parse(response.body)

      expect(json['links']['first']).to be_present
      expect(json['links']['prev']).to be_present
      expect(json['links']['next']).to be_present
      expect(json['links']['last']).to be_present
    end
  end
end
```

## Best Practices

1. **Always set max per_page**: Prevent abuse with reasonable limits (e.g., 100)
2. **Include pagination metadata**: Help clients understand available data
3. **Provide navigation links**: Make it easy to traverse pages
4. **Use Link headers for simple APIs**: Keep response body clean
5. **Cache total counts**: Expensive on large tables
6. **Consider cursor pagination**: Better for real-time feeds
7. **Document pagination**: Clear API docs with examples
8. **Handle out of range gracefully**: Return empty array, not errors
9. **Preserve query parameters**: Keep filters/sorts in pagination links
10. **Use consistent format**: Pick one pagination style and stick with it
