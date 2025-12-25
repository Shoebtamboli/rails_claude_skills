---
paths: app/views/**/*,app/controllers/**/*
---

# Hotwire Rules

Guidelines for using Turbo and Stimulus in this Rails application.

## Turbo Principles

- **Turbo Drive**: Automatically handles link clicks and form submissions
- **Turbo Frames**: Use for independent page segments
- **Turbo Streams**: Use for real-time updates and multiple page updates

## When to Use What

### Turbo Frames
- Independent sections of a page
- Inline editing
- Lazy-loaded content
- Modal dialogs

### Turbo Streams
- Real-time updates (via WebSocket)
- Multiple simultaneous page updates
- Optimistic UI updates
- Background job results

### Stimulus
- Client-side interactivity
- Form validation
- UI enhancements
- When Turbo alone isn't sufficient

## Best Practices

- Prefer Turbo over custom JavaScript
- Keep Stimulus controllers small and focused
- Use semantic HTML with Turbo
- Follow progressive enhancement
- Test Turbo interactions

## Common Patterns

- Use `data-turbo-frame` for targeting frames
- Use `turbo_stream_from` for real-time updates
- Respond with `turbo_stream` format in controllers
- Use Stimulus for UI state management
- Leverage Turbo's morphing for smooth updates

## Performance

- Lazy load Turbo Frames when appropriate
- Cache Turbo Frame responses
- Use Turbo Stream broadcasts efficiently
- Minimize JavaScript controller complexity
