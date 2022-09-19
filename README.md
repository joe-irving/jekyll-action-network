# Jekyll::ActionNetwork

A Jekyll::Generator that brings your action network events, petitions etc into a neat jekyll site.

## Installation

Add this line to your site's Gemfile:

```ruby
gem 'jekyll-action-network'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install jekyll-action-network

## Usage

In you `_config.yml` file in the root directory of your jekyll site, add `gem "jekyll-action-network"` under plugins: 

```yaml
plugins:
  - jekyll-action-network
```

then add in the config for importing from Action Network. To get started, all you need is:

```yaml
action_network:
    # Add your api key to a .env file
    key: ENV_YOUR_API_KEY
    # And your collections from action network you want to import
    import:
      - events
      - petitions
```

Or, if your API key is called `ACTION_NETWORK_API_KEY` in the projects environment (including in a .env file):

```yaml
action_network:
  import:
    - events
    - petitions
```

Here is the full default configuration:

```yaml
action_network:
  # Your API Key
  key: ENV_ACTION_NETWORK_API_KEY
  # Combine all action network actions into one collection. Can be set to 'false' to turn off
  actions: 
    name: actions
  # Which collections should be imported. Can be a list of strings:
  # - petitions
  # - events # etc..
  # or hashes as below:
  import:
      # The name in action network
    - name: petitions
      # The collection name in Jekyll
      collection: petitions
      # The layout to use in the _layouts folder
      layout: an-petition 
      # Which field to use as the markup content
      content: description
      # Which feilds to map to the font matter of each page.
      # In the format:
      # action_network: front_matter
      mappings:
        title: title
        description: description
        petition_text: petition_text
        browser_url: browser_url
        featured_image_url: image
        target: target
        "action_network:sponsor": sponsor
    - name: events
      collection: events
      layout: an-event
      content: description
      mappings:
        title: title
        description: description
        browser_url: browser_url
        featured_image_url: image
        start_date: start_date
        end_date: end_date
        location: location
        "action_network:event_campaign_id": event_campaign_id
        status: status
        visibility: visibility
        capacity: capacity
        "action_network:sponsor": sponsor
    - name: event_campaigns
      collection: event_campaigns
      layout: an-event_campaign
      content: description
      mappings:
        title: title
        description: description
        browser_url: browser_url
        featured_image_url: image
        host_url: host_url
        total_events: total_events
        total_rsvps: total_rsvps
        "action_network:sponsor": sponsor
```

### Templating your collections

To make sure your collections are being created as pages, add these to your config like normal

```yaml
collections:
    events:
        output: true
```

Then, if you are using the default configuration, create template files in the `_layouts` folder. e.g for events and petitions:

```
├── _layouts
|  ├── an-event.html
|  ├── an-petitions.html
```

See the example website in the `example` folder for this in action.


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/jekyll-action-network. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/jekyll-gdocfilter/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Jekyll::ActionNetwork project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/jekyll-gdocfilter/blob/master/CODE_OF_CONDUCT.md).
