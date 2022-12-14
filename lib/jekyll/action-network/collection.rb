# frozen_string_literal: true

module Jekyll
  module ActionNetwork
    ##
    # For creating Jekyll::Collections from an Action Network config
    #
    class Collection
      UTILS = Jekyll::ActionNetwork::Utils.new

      def initialize(site, generator, client, config_init, settings)
        @site = site
        @generator = generator
        @settings = settings
        @client = client
        @config_init = config_init
      end

      def config
        @name = @config_init["name"]
        @defaults ||= @settings["defaults"]
        @config ||= @defaults[@name].merge!(@config_init)
      end

      def collection
        return @collection if @collection

        Jekyll.logger.debug LOG_NAME, "Creating collection #{@name}"
        @collection ||= @site.collections[@name] if @site.collections[@name]
        @collection ||= Jekyll::Collection.new(@site, config["collection"])
      end

      def documents
        documents = []
        filtered_actions.each do |action_data|
          action = Jekyll::ActionNetwork::Action.new(@site, @name, collection, config, action_data, @settings)
          documents << action.doc
        end
        documents
      end

      def populate
        collection.docs.concat(documents)
        @collection
      end

      def actions
        return @actions if @actions

        @actions = @client.send(@name).all
        @actions.concat(all_ec_events) if @name == "events" && config["include_event_campaigns"]
        @actions.uniq(&:action_network_id)
      end

      def all_ec_events
        event_campaigns = @client.event_campaigns.all
        events = []
        event_campaigns.each do |event_campaign|
          ec_client = @client.event_campaigns(event_campaign.action_network_id)
          events.concat(ec_client.events.all)
        end
        events
      end

      def filters
        filters = @settings["filters"]["all"].merge(@settings["filters"][@name] || {})
        filters.merge(config["filters"] || {})
      end

      def filtered_actions
        public_actions = []
        actions.each do |action|
          next if action_filtered(action, filters)

          public_actions << reduce_fields(action)
        end
      end

      def action_filtered(action, filters)
        filtered = false
        filters.each do |key, value|
          next if action[key] == value

          next if value == "%" && action[key]

          Jekyll.logger.debug @log_name, "#{action["title"]} filtered because #{action[key]} == #{value}"
          filtered = true
          break
        end
        filtered
      end

      def reduce_fields(action)
        reduced_action = {}
        @settings["fields"].each do |field|
          reduced_action[field] = action[field] if action[field]
        end
        reduced_action
      end
    end
  end
end
