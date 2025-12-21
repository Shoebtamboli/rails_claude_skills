# Custom Themes for Kaminari

Guide to creating and customizing pagination themes for different UI frameworks and design systems.

## Generating Theme Templates

```bash
# Generate default theme to customize
rails g kaminari:views default

# Generate with custom namespace
rails g kaminari:views default --views-prefix admin

# Generate Bootstrap 4 theme
rails g kaminari:views bootstrap4

# Generate Bootstrap 5 theme
rails g kaminari:views bootstrap5

# Generate Tailwind theme
rails g kaminari:views tailwind
```

## Template Files Structure

Generated templates appear in `app/views/kaminari/`:

```
app/views/kaminari/
├── _paginator.html.erb      # Main wrapper
├── _first_page.html.erb      # First page link
├── _prev_page.html.erb       # Previous page link
├── _page.html.erb            # Regular page link
├── _next_page.html.erb       # Next page link
├── _last_page.html.erb       # Last page link
└── _gap.html.erb             # Ellipsis/gap between pages
```

## Creating a Custom Theme

### Tailwind CSS Theme

```bash
# Create theme directory
mkdir -p app/views/kaminari/tailwind
```

```erb
<!-- app/views/kaminari/tailwind/_paginator.html.erb -->
<nav aria-label="Page navigation" class="flex justify-center my-8">
  <ul class="flex space-x-2">
    <%= first_page_tag unless current_page.first? %>
    <%= prev_page_tag unless current_page.first? %>

    <% each_page do |page| %>
      <% if page.left_outer? || page.right_outer? || page.inside_window? %>
        <%= page_tag page %>
      <% elsif !page.was_truncated? -%>
        <%= gap_tag %>
      <% end %>
    <% end %>

    <%= next_page_tag unless current_page.last? %>
    <%= last_page_tag unless current_page.last? %>
  </ul>
</nav>

<!-- app/views/kaminari/tailwind/_page.html.erb -->
<% if page.current? %>
  <li>
    <span class="px-3 py-2 text-sm font-medium text-white bg-blue-600 rounded-md">
      <%= page %>
    </span>
  </li>
<% else %>
  <li>
    <%= link_to page, url, remote: remote, rel: page.rel, class: 'px-3 py-2 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-md hover:bg-gray-50' %>
  </li>
<% end %>

<!-- app/views/kaminari/tailwind/_first_page.html.erb -->
<li>
  <%= link_to_unless current_page.first?, t('views.pagination.first').html_safe, url, remote: remote, class: 'px-3 py-2 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-md hover:bg-gray-50' %>
</li>

<!-- app/views/kaminari/tailwind/_prev_page.html.erb -->
<li>
  <%= link_to_unless current_page.first?, t('views.pagination.previous').html_safe, url, rel: 'prev', remote: remote, class: 'px-3 py-2 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-md hover:bg-gray-50' %>
</li>

<!-- app/views/kaminari/tailwind/_next_page.html.erb -->
<li>
  <%= link_to_unless current_page.last?, t('views.pagination.next').html_safe, url, rel: 'next', remote: remote, class: 'px-3 py-2 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-md hover:bg-gray-50' %>
</li>

<!-- app/views/kaminari/tailwind/_last_page.html.erb -->
<li>
  <%= link_to_unless current_page.last?, t('views.pagination.last').html_safe, url, remote: remote, class: 'px-3 py-2 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-md hover:bg-gray-50' %>
</li>

<!-- app/views/kaminari/tailwind/_gap.html.erb -->
<li>
  <span class="px-3 py-2 text-sm font-medium text-gray-700">
    <%= t('views.pagination.truncate').html_safe %>
  </span>
</li>
```

### Using the Theme

```erb
<%= paginate @posts, theme: 'tailwind' %>
```

## Bootstrap 5 Theme

```erb
<!-- app/views/kaminari/bootstrap5/_paginator.html.erb -->
<nav aria-label="Page navigation">
  <ul class="pagination justify-content-center">
    <%= first_page_tag unless current_page.first? %>
    <%= prev_page_tag unless current_page.first? %>

    <% each_page do |page| %>
      <% if page.left_outer? || page.right_outer? || page.inside_window? %>
        <%= page_tag page %>
      <% elsif !page.was_truncated? -%>
        <%= gap_tag %>
      <% end %>
    <% end %>

    <%= next_page_tag unless current_page.last? %>
    <%= last_page_tag unless current_page.last? %>
  </ul>
</nav>

<!-- app/views/kaminari/bootstrap5/_page.html.erb -->
<li class="page-item <%= 'active' if page.current? %>">
  <%= link_to page, url, remote: remote, rel: page.rel, class: 'page-link' %>
</li>

<!-- app/views/kaminari/bootstrap5/_first_page.html.erb -->
<li class="page-item">
  <%= link_to_unless current_page.first?, raw(t 'views.pagination.first'), url, remote: remote, class: 'page-link' %>
</li>

<!-- app/views/kaminari/bootstrap5/_prev_page.html.erb -->
<li class="page-item">
  <%= link_to_unless current_page.first?, raw(t 'views.pagination.previous'), url, rel: 'prev', remote: remote, class: 'page-link' %>
</li>

<!-- app/views/kaminari/bootstrap5/_next_page.html.erb -->
<li class="page-item">
  <%= link_to_unless current_page.last?, raw(t 'views.pagination.next'), url, rel: 'next', remote: remote, class: 'page-link' %>
</li>

<!-- app/views/kaminari/bootstrap5/_last_page.html.erb -->
<li class="page-item">
  <%= link_to_unless current_page.last?, raw(t 'views.pagination.last'), url, remote: remote, class: 'page-link' %>
</li>

<!-- app/views/kaminari/bootstrap5/_gap.html.erb -->
<li class="page-item disabled">
  <span class="page-link"><%= raw(t 'views.pagination.truncate') %></span>
</li>
```

## Bulma CSS Theme

```erb
<!-- app/views/kaminari/bulma/_paginator.html.erb -->
<nav class="pagination is-centered" role="navigation" aria-label="pagination">
  <%= prev_page_tag unless current_page.first? %>
  <%= next_page_tag unless current_page.last? %>

  <ul class="pagination-list">
    <%= first_page_tag unless current_page.first? %>

    <% each_page do |page| %>
      <% if page.left_outer? || page.right_outer? || page.inside_window? %>
        <%= page_tag page %>
      <% elsif !page.was_truncated? -%>
        <%= gap_tag %>
      <% end %>
    <% end %>

    <%= last_page_tag unless current_page.last? %>
  </ul>
</nav>

<!-- app/views/kaminari/bulma/_page.html.erb -->
<li>
  <% if page.current? %>
    <a class="pagination-link is-current" aria-current="page"><%= page %></a>
  <% else %>
    <%= link_to page, url, remote: remote, rel: page.rel, class: 'pagination-link' %>
  <% end %>
</li>

<!-- app/views/kaminari/bulma/_prev_page.html.erb -->
<%= link_to_unless current_page.first?, raw(t 'views.pagination.previous'), url, rel: 'prev', remote: remote, class: 'pagination-previous' %>

<!-- app/views/kaminari/bulma/_next_page.html.erb -->
<%= link_to_unless current_page.last?, raw(t 'views.pagination.next'), url, rel: 'next', remote: remote, class: 'pagination-next' %>

<!-- app/views/kaminari/bulma/_gap.html.erb -->
<li>
  <span class="pagination-ellipsis">&hellip;</span>
</li>
```

## Foundation Theme

```erb
<!-- app/views/kaminari/foundation/_paginator.html.erb -->
<ul class="pagination text-center" role="navigation" aria-label="Pagination">
  <%= first_page_tag unless current_page.first? %>
  <%= prev_page_tag unless current_page.first? %>

  <% each_page do |page| %>
    <% if page.left_outer? || page.right_outer? || page.inside_window? %>
      <%= page_tag page %>
    <% elsif !page.was_truncated? -%>
      <%= gap_tag %>
    <% end %>
  <% end %>

  <%= next_page_tag unless current_page.last? %>
  <%= last_page_tag unless current_page.last? %>
</ul>

<!-- app/views/kaminari/foundation/_page.html.erb -->
<li class="<%= 'current' if page.current? %>">
  <%= link_to_unless page.current?, page, url, remote: remote, rel: page.rel %>
</li>

<!-- app/views/kaminari/foundation/_gap.html.erb -->
<li class="ellipsis" aria-hidden="true"></li>
```

## Minimal/Simple Theme

For projects that want simple text-based pagination:

```erb
<!-- app/views/kaminari/simple/_paginator.html.erb -->
<div class="simple-pagination">
  <%= prev_page_tag unless current_page.first? %>
  <span class="page-info">
    Page <%= current_page %> of <%= total_pages %>
  </span>
  <%= next_page_tag unless current_page.last? %>
</div>

<!-- app/views/kaminari/simple/_prev_page.html.erb -->
<%= link_to_unless current_page.first?, '← Previous', url, rel: 'prev', remote: remote, class: 'prev-page' %>

<!-- app/views/kaminari/simple/_next_page.html.erb -->
<%= link_to_unless current_page.last?, 'Next →', url, rel: 'next', remote: remote, class: 'next-page' %>
```

```css
/* app/assets/stylesheets/pagination.css */
.simple-pagination {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 1rem 0;
}

.page-info {
  color: #666;
}

.prev-page,
.next-page {
  padding: 0.5rem 1rem;
  text-decoration: none;
  color: #007bff;
}

.prev-page:hover,
.next-page:hover {
  text-decoration: underline;
}
```

## Icon-Based Navigation

Using Font Awesome or other icon libraries:

```erb
<!-- app/views/kaminari/icons/_prev_page.html.erb -->
<li>
  <%= link_to_unless current_page.first?, url, rel: 'prev', remote: remote, class: 'page-link' do %>
    <i class="fas fa-chevron-left"></i>
    <span class="sr-only">Previous</span>
  <% end %>
</li>

<!-- app/views/kaminari/icons/_next_page.html.erb -->
<li>
  <%= link_to_unless current_page.last?, url, rel: 'next', remote: remote, class: 'page-link' do %>
    <span class="sr-only">Next</span>
    <i class="fas fa-chevron-right"></i>
  <% end %>
</li>

<!-- app/views/kaminari/icons/_first_page.html.erb -->
<li>
  <%= link_to_unless current_page.first?, url, remote: remote, class: 'page-link' do %>
    <i class="fas fa-angle-double-left"></i>
    <span class="sr-only">First</span>
  <% end %>
</li>

<!-- app/views/kaminari/icons/_last_page.html.erb -->
<li>
  <%= link_to_unless current_page.last?, url, remote: remote, class: 'page-link' do %>
    <span class="sr-only">Last</span>
    <i class="fas fa-angle-double-right"></i>
  <% end %>
</li>
```

## Multiple Themes in One App

```ruby
# app/controllers/posts_controller.rb
class PostsController < ApplicationController
  def index
    @posts = Post.page(params[:page])
  end
end

# app/controllers/admin/posts_controller.rb
module Admin
  class PostsController < AdminController
    def index
      @posts = Post.page(params[:page])
    end
  end
end
```

```erb
<!-- app/views/posts/index.html.erb -->
<%= paginate @posts, theme: 'tailwind' %>

<!-- app/views/admin/posts/index.html.erb -->
<%= paginate @posts, theme: 'bootstrap5' %>
```

## Helper Methods in Templates

Available helper methods in pagination templates:

```erb
<!-- Access pagination metadata -->
<%= total_pages %>      <!-- Total number of pages -->
<%= current_page %>     <!-- Current page number -->
<%= per_page %>         <!-- Items per page -->

<!-- Available page variables in each_page block -->
<% each_page do |page| %>
  <%= page.number %>         <!-- Page number -->
  <%= page.current? %>       <!-- Is this the current page? -->
  <%= page.first? %>         <!-- Is this the first page? -->
  <%= page.last? %>          <!-- Is this the last page? -->
  <%= page.next? %>          <!-- Is this the next page? -->
  <%= page.prev? %>          <!-- Is this the previous page? -->
  <%= page.left_outer? %>    <!-- In left outer window? -->
  <%= page.right_outer? %>   <!-- In right outer window? -->
  <%= page.inside_window? %> <!-- Inside main window? -->
  <%= page.was_truncated? %> <!-- Was truncated? -->
  <%= page.rel %>            <!-- Rel attribute value -->
<% end %>
```

## Responsive Pagination

```erb
<!-- app/views/kaminari/responsive/_paginator.html.erb -->
<nav aria-label="Page navigation">
  <!-- Mobile: Simple prev/next only -->
  <ul class="pagination d-md-none">
    <%= prev_page_tag unless current_page.first? %>
    <li class="page-item disabled">
      <span class="page-link">Page <%= current_page %> of <%= total_pages %></span>
    </li>
    <%= next_page_tag unless current_page.last? %>
  </ul>

  <!-- Desktop: Full pagination -->
  <ul class="pagination d-none d-md-flex">
    <%= first_page_tag unless current_page.first? %>
    <%= prev_page_tag unless current_page.first? %>

    <% each_page do |page| %>
      <% if page.left_outer? || page.right_outer? || page.inside_window? %>
        <%= page_tag page %>
      <% elsif !page.was_truncated? -%>
        <%= gap_tag %>
      <% end %>
    <% end %>

    <%= next_page_tag unless current_page.last? %>
    <%= last_page_tag unless current_page.last? %>
  </ul>
</nav>
```

## Accessibility Best Practices

```erb
<!-- app/views/kaminari/accessible/_paginator.html.erb -->
<nav role="navigation" aria-label="Pagination Navigation" class="pagination-wrapper">
  <ul class="pagination">
    <%= first_page_tag unless current_page.first? %>
    <%= prev_page_tag unless current_page.first? %>

    <% each_page do |page| %>
      <% if page.left_outer? || page.right_outer? || page.inside_window? %>
        <%= page_tag page %>
      <% elsif !page.was_truncated? -%>
        <%= gap_tag %>
      <% end %>
    <% end %>

    <%= next_page_tag unless current_page.last? %>
    <%= last_page_tag unless current_page.last? %>
  </ul>
</nav>

<!-- app/views/kaminari/accessible/_page.html.erb -->
<li>
  <% if page.current? %>
    <span class="page-link current" aria-current="page" aria-label="Page <%= page %>, current page">
      <%= page %>
    </span>
  <% else %>
    <%= link_to page, url, remote: remote, rel: page.rel, class: 'page-link', 'aria-label': "Go to page #{page}" %>
  <% end %>
</li>

<!-- app/views/kaminari/accessible/_prev_page.html.erb -->
<li>
  <% unless current_page.first? %>
    <%= link_to url, rel: 'prev', remote: remote, class: 'page-link', 'aria-label': 'Go to previous page' do %>
      <span aria-hidden="true">&laquo;</span>
      <span class="sr-only">Previous</span>
    <% end %>
  <% end %>
</li>
```

## Testing Custom Themes

```ruby
# spec/views/posts/index.html.erb_spec.rb
require 'rails_helper'

RSpec.describe 'posts/index', type: :view do
  let(:posts) { Kaminari.paginate_array((1..100).to_a).page(2).per(10) }

  before do
    assign(:posts, posts)
    render
  end

  it 'renders pagination with custom theme' do
    expect(rendered).to have_css('nav.pagination')
    expect(rendered).to have_link('Previous')
    expect(rendered).to have_link('Next')
  end

  it 'shows current page as active' do
    expect(rendered).to have_css('.page-item.active', text: '2')
  end

  it 'includes accessibility attributes' do
    expect(rendered).to have_css('[aria-label="Pagination"]')
  end
end
```

## Best Practices

1. **Use semantic HTML**: Wrap pagination in `<nav>` with proper ARIA labels
2. **Make links accessible**: Include screen-reader text for icon-only links
3. **Indicate current page**: Use `aria-current="page"` and visual styling
4. **Support keyboard navigation**: Ensure links are focusable and have clear focus states
5. **Be responsive**: Consider mobile-friendly pagination on small screens
6. **Use consistent styling**: Match your application's design system
7. **Test thoroughly**: Verify pagination works across browsers and devices
8. **Maintain theme consistency**: Keep all partials in same theme directory
9. **Document custom themes**: Comment complex logic in templates
10. **Version control themes**: Track theme changes alongside code
