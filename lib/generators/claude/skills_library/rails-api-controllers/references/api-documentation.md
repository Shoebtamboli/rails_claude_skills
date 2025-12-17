# API Documentation with OpenAPI/Swagger

Generate interactive API documentation automatically using Rswag or other OpenAPI tools.

## Rswag Setup

Rswag integrates OpenAPI (Swagger) documentation with RSpec tests, keeping docs in sync with implementation.

### Installation

```ruby
# Gemfile
group :development, :test do
  gem 'rswag'
end

# Install
bundle install
rails g rswag:install
```

This creates:
- `spec/swagger_helper.rb` - OpenAPI configuration
- `swagger/v1/swagger.yaml` - Generated API spec
- Swagger UI at `/api-docs`

### Configuration

```ruby
# spec/swagger_helper.rb
RSpec.configure do |config|
  config.swagger_root = Rails.root.join('swagger').to_s

  config.swagger_docs = {
    'v1/swagger.yaml' => {
      openapi: '3.0.1',
      info: {
        title: 'My API V1',
        version: 'v1',
        description: 'RESTful API for MyApp'
      },
      paths: {},
      servers: [
        {
          url: 'https://api.example.com',
          description: 'Production'
        },
        {
          url: 'http://localhost:3000',
          description: 'Development'
        }
      ],
      components: {
        securitySchemes: {
          bearer_auth: {
            type: :http,
            scheme: :bearer,
            bearerFormat: 'JWT'
          },
          api_token: {
            type: :apiKey,
            name: 'Authorization',
            in: :header
          }
        }
      }
    }
  }

  config.swagger_format = :yaml
end
```

## Writing API Specs with Rswag

Document endpoints using RSpec integration tests:

### Basic Endpoint Documentation

```ruby
# spec/requests/api/v1/articles_spec.rb
require 'swagger_helper'

RSpec.describe 'Api::V1::Articles', type: :request do
  path '/api/v1/articles' do
    get 'List all articles' do
      tags 'Articles'
      produces 'application/json'
      security [{ bearer_auth: [] }]

      parameter name: :page, in: :query, type: :integer, required: false,
                description: 'Page number'
      parameter name: :per_page, in: :query, type: :integer, required: false,
                description: 'Items per page'
      parameter name: :status, in: :query, type: :string, required: false,
                description: 'Filter by status', enum: ['draft', 'published', 'archived']

      response '200', 'articles found' do
        schema type: :object,
               properties: {
                 data: {
                   type: :array,
                   items: {
                     type: :object,
                     properties: {
                       id: { type: :integer },
                       title: { type: :string },
                       body: { type: :string },
                       status: { type: :string },
                       created_at: { type: :string, format: :datetime }
                     }
                   }
                 },
                 meta: {
                   type: :object,
                   properties: {
                     current_page: { type: :integer },
                     total_pages: { type: :integer },
                     total_count: { type: :integer }
                   }
                 }
               }

        let(:Authorization) { "Bearer #{user.api_token}" }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['data']).to be_an(Array)
        end
      end

      response '401', 'unauthorized' do
        schema type: :object,
               properties: {
                 error: { type: :string }
               }

        let(:Authorization) { 'Bearer invalid_token' }
        run_test!
      end
    end

    post 'Create an article' do
      tags 'Articles'
      consumes 'application/json'
      produces 'application/json'
      security [{ bearer_auth: [] }]

      parameter name: :article, in: :body, schema: {
        type: :object,
        properties: {
          article: {
            type: :object,
            properties: {
              title: { type: :string },
              body: { type: :string },
              status: { type: :string, enum: ['draft', 'published'] }
            },
            required: ['title', 'body']
          }
        }
      }

      response '201', 'article created' do
        schema type: :object,
               properties: {
                 id: { type: :integer },
                 title: { type: :string },
                 body: { type: :string },
                 status: { type: :string }
               }

        let(:Authorization) { "Bearer #{user.api_token}" }
        let(:article) { { article: { title: 'Test', body: 'Content' } } }

        run_test!
      end

      response '422', 'invalid request' do
        schema type: :object,
               properties: {
                 error: { type: :string },
                 details: { type: :array, items: { type: :string } }
               }

        let(:Authorization) { "Bearer #{user.api_token}" }
        let(:article) { { article: { title: '' } } }

        run_test!
      end
    end
  end

  path '/api/v1/articles/{id}' do
    parameter name: :id, in: :path, type: :integer, description: 'Article ID'

    get 'Show an article' do
      tags 'Articles'
      produces 'application/json'
      security [{ bearer_auth: [] }]

      response '200', 'article found' do
        schema type: :object,
               properties: {
                 id: { type: :integer },
                 title: { type: :string },
                 body: { type: :string },
                 status: { type: :string },
                 author: {
                   type: :object,
                   properties: {
                     id: { type: :integer },
                     name: { type: :string }
                   }
                 }
               }

        let(:id) { article.id }
        let(:Authorization) { "Bearer #{user.api_token}" }

        run_test!
      end

      response '404', 'article not found' do
        let(:id) { 'invalid' }
        let(:Authorization) { "Bearer #{user.api_token}" }

        run_test!
      end
    end

    delete 'Delete an article' do
      tags 'Articles'
      security [{ bearer_auth: [] }]

      response '204', 'article deleted' do
        let(:id) { article.id }
        let(:Authorization) { "Bearer #{user.api_token}" }

        run_test!
      end
    end
  end
end
```

## Generating Documentation

```bash
# Generate OpenAPI spec from tests
rake rswag:specs:swaggerize

# This generates swagger/v1/swagger.yaml
```

## Accessing Documentation

**Swagger UI:**
- Development: `http://localhost:3000/api-docs`
- Production: `https://api.example.com/api-docs`

Interactive UI allows:
- Browsing all endpoints
- Trying out requests
- Viewing request/response schemas
- Testing authentication

## Shared Schemas

Define reusable schemas:

```ruby
# spec/swagger_helper.rb
config.swagger_docs = {
  'v1/swagger.yaml' => {
    # ... other config ...
    components: {
      schemas: {
        Article: {
          type: :object,
          properties: {
            id: { type: :integer },
            title: { type: :string },
            body: { type: :string },
            status: { type: :string, enum: ['draft', 'published', 'archived'] },
            created_at: { type: :string, format: :datetime },
            updated_at: { type: :string, format: :datetime }
          },
          required: ['title', 'body']
        },
        Error: {
          type: :object,
          properties: {
            error: { type: :string },
            details: { type: :array, items: { type: :string } }
          }
        }
      }
    }
  }
}

# Use in specs
response '200', 'success' do
  schema '$ref' => '#/components/schemas/Article'
  run_test!
end

response '422', 'validation error' do
  schema '$ref' => '#/components/schemas/Error'
  run_test!
end
```

## Best Practices

1. **Keep Tests as Documentation**
   - Rswag tests serve dual purpose: testing and documentation
   - Every endpoint should have at least one documented test

2. **Document All Responses**
   - Include success (200, 201, 204)
   - Include errors (400, 401, 403, 404, 422, 500)
   - Define response schemas

3. **Use Examples**
   ```ruby
   response '200', 'success' do
     schema type: :object,
            properties: { name: { type: :string } },
            example: { name: 'John Doe' }
     run_test!
   end
   ```

4. **Tag Endpoints**
   - Group related endpoints with tags
   - Tags become sections in Swagger UI

5. **Security Schemes**
   - Document authentication requirements
   - Show how to authenticate in Swagger UI

## Alternative: Blueprint/OpenAPI Generator

For non-test-based documentation:

```ruby
# Gemfile
gem 'rspec-openapi'

# Generate OpenAPI from request specs
OPENAPI=1 rspec spec/requests
```

## Publishing Documentation

### Static Site

```bash
# Generate static HTML
docker run -v $(pwd)/swagger:/swagger \
  swaggerapi/swagger-ui \
  swagger-ui-cli bundle /swagger/v1/swagger.yaml

# Serve static files
```

### Documentation Hosting

- **SwaggerHub**: Upload OpenAPI spec
- **Readme.io**: Import OpenAPI spec
- **Postman**: Import for collection testing

## Example Output

After running `rake rswag:specs:swaggerize`, you get:

```yaml
# swagger/v1/swagger.yaml
openapi: 3.0.1
info:
  title: My API V1
  version: v1
paths:
  /api/v1/articles:
    get:
      summary: List all articles
      tags:
        - Articles
      security:
        - bearer_auth: []
      parameters:
        - name: page
          in: query
          required: false
          schema:
            type: integer
      responses:
        '200':
          description: articles found
          content:
            application/json:
              schema:
                type: object
                properties:
                  data:
                    type: array
                    items:
                      type: object
                      properties:
                        id:
                          type: integer
                        title:
                          type: string
```

This YAML can be:
- Viewed in Swagger UI
- Imported into Postman
- Used by API clients for code generation
- Shared with frontend developers
