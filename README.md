# Filterable

A lightweight ActiveRecord concern that lets you combine named scopes into
composable filter queries with **AND** / **OR** operators.

Define scopes on your model, pass a hash of `{ scope_name: value }` pairs to
`.filter`, and Filterable chains them together for you.

## Installation

Add to your Gemfile:

```ruby
gem "filterable", git: "https://github.com/Master-Branch-Software/filterable"
```

Or install directly:

```
gem install filterable
```

## Usage

### 1. Include the concern

```ruby
class Article < ActiveRecord::Base
  include Filterable::Concern

  scope :for_status, ->(status)    { where(status: status) }
  scope :for_author, ->(author_id) { where(author_id: author_id) }
  scope :for_tag,    ->(tag_ids)   { joins(:tags).where(tags: { id: tag_ids }).distinct }
end
```

### 2. Filter with AND (default)

Every scope must match. This is the default behavior.

```ruby
Article.filter(for_status: "published", for_author: 1)
# => SELECT * FROM articles WHERE status = 'published' AND author_id = 1

Article.filter({ for_status: "published", for_author: 1 }, operator: :and)
# equivalent to the above
```

### 3. Filter with OR

Records matching **any** scope are returned.

```ruby
Article.filter(
  { for_status: "published", for_author: 1 },
  operator: :or
)
# => returns articles that are published OR authored by user 1
```

### 4. Blank / nil filters

When `filters` is `nil`, empty, or all values are `nil`, `.filter` returns
the unscoped relation (all records). Individual `nil` values inside the hash
are automatically stripped before filtering.

```ruby
Article.filter(nil)            # => all articles
Article.filter({})             # => all articles
Article.filter(for_author: nil) # => all articles (nil value compacted out)
```

## How it works

- **AND mode** chains each scope sequentially with `public_send`, producing a
  single query with all conditions.
- **OR mode** evaluates each scope independently, collects the matching IDs,
  then returns records whose `id` is in the union of those sets.
- An `ArgumentError` is raised if an unsupported operator is passed.

## Requirements

- Ruby >= 3.0
- ActiveRecord >= 6.0

## Development

```bash
bundle install
bundle exec rspec
```

## License

MIT — see [LICENSE.txt](LICENSE.txt).

Copyright (c) 2026 MasterBranch Software, LLC — [www.masterbranch.com](https://www.masterbranch.com)
