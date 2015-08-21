# Diffit

A simple solution to track changes in your tables.

> Right now with PostgreSQL support only

<a href="https://evilmartians.com/?utm_source=gon">
<img src="https://evilmartians.com/badges/sponsored-by-evil-martians.svg" alt="Sponsored by Evil Martians" width="236" height="54">
</a>

# Installation

## In Gemfile:

    gem 'diffit'

## Generators

### Initializer

    rails g diffit:init

Creates `initializer` in which you can put names of tracking table and stored procedure.
Trigger names will be generated around corresponding table and stored procedure.

### Structure migration

    rails g diffit:structure

Creates migrations for tracking table and stored procedure using data from `config/initializers/diffit.rb`.

### Triggers migration

    rails g diffit:triggers TABLE_NAME

Creates triggers for `INSERT` and `UPDATE` actions on corresponding table.
Assumes it should got real table name.
Otherwise attempts to get a table name from corresponding class.

## In your app

In **diffit**-related model:

```ruby
class Post < ActiveRecord::Base
  diffit
end
```

# Usage:

```ruby
# Let's track something.
tracker = Diffit::Tracker.new(5.days.ago)

# For example, let's track a Post with ID=3.
tracker.append(Post.find(3))

# And all Authors with high rating.
tracker.append(Authors.where('rating > ?', 100))

# And a 'Whatever' model. Whatever.
tracker.append(Whatever)

# By the way, it's chainable ;)
tracker.append(Post.where(author_id: 2)).append(Post.where(author_id: 3))

# Finally, let's take a look at it.
tracker.to_h

# And in JSON, please.
tracker.to_json

# To iterate or not?..
tracker.each do |record|
  # do somethings with record.model, record.record_id or record.changes
end

# But what about models? Ah-ha yeah!
Author.last.posts.where('posts.views_count > ?', 1000).where('posts.answers_count > 20').where(subject_id: 42).actual.changes_since(1.week.ago)
# Tons of data here. Sorry.

# Tired of this shit?
tracker.all
```

# Tests

In spec/dummy

    rake db:create RAILS_ENV=test
    rake db:migrate RAILS_ENV=test

In project root

    rspec spec

# Licence

MIT-LICENSE
