# Typhoid

[![TravisCI](https://secure.travis-ci.org/tstmedia/typhoid.png "TravisCI")](http://travis-ci.org/tstmedia/typhoid "Travis-CI Typhoid")

A lightweight ORM-like wrapper around [Typhoeus](http://typhoeus.github.com/)

## Installation

Add this line to your application's Gemfile:

    gem 'typhoid'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install typhoid

## Usage

### Class Setup

```ruby
require 'typhoid'

class Game < Typhoid::Resource
  field :id
  field :team_1_name
  field :team_2_name
  field :start_time

  self.site = 'http://localhost:3000/'  # The base-url for where we plan to retrieve data
  self.path = 'games/'                  # Specific path to get the data for this Class

  def self.get_game
    build_request("http://localhost:3000/games/1")
  end
end
```

A `field` creates a accessor methods that can be mass-assigned:

```ruby
g = Game.new id: 1, team_1_name: "Team 1", start_time: Time.now

g.id                # => 1
g.team_1_name       # => "Team 1"
g.team_2_name       # => nil
g.start_time        # => #<Time: ...>

g.team_2_name = "Team 2"
g.team_2_name       # => "Team 2"
```

These fields will be set on request and will be

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Write some tests (Yes now.. [`vim spec/...`])
4. Commit your changes (`git commit -am 'Added some feature'`)
5. Push to the branch (`git push origin my-new-feature`)
6. Create new Pull Request
