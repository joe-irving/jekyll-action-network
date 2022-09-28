# frozen_string_literal: true

require "action_network_rest"
require "jekyll"
require "yaml"
require "dotenv/load"

module Jekyll
  ##
  # An integration with Action Network for a Jekyll site
  module ActionNetwork
    LOG_NAME = "Action Network: "

    ##
    # Generates Jekyll collections from the Action Network API
    class Generator < Jekyll::Generator
      UTILS = Jekyll::ActionNetwork::Utils.new

      def generate(site)
        return unless site.config["action_network"]

        @site = site
        @config = site.config["action_network"]
        @utils = Jekyll::ActionNetwork::Utils.new
        return unless authenticate

        make_collections
        # site.config['action_network']['generated'] = true
      end

      def make_collections
        @config["import"].each do |config|
          col_config = make_collection_config(config)
          name = col_config["name"]
          next unless col_config["name"]

          make_collection(name, col_config)
        end
        @site.collections["actions"] = actions if @config["actions"]
      end

      def make_collection_config(col_config_init)
        return col_config_init if col_config_init.is_a? Hash
        return { "name" => col_config_init } if col_config_init.is_a? String

        Jekyll.logger.warn LOG_NAME, "Config format #{col_config_init} not recognised"
      end

      def make_collection(name, config)
        return unless defaults[name]

        collection = Jekyll::ActionNetwork::Collection.new(@site, self, @client, config, settings)
        @site.collections[collection.config["collection"]] = collection.populate
        actions.docs.concat(collection.collection.docs)
      end

      def actions
        return @actions if @actions

        actions_config = @config["actions"] if @config["actions"].is_a? Hash
        actions_settings = settings["actions"].merge(actions_config || {})
        @actions ||= Jekyll::Collection.new(@site, actions_settings["collection"])
      end

      def settings
        return @settings if @settings

        settings = YAML.load_file("#{File.expand_path(__dir__)}/settings.yaml")
        @fields = settings["fields"]
        @filters = settings["filters"]
        @settings = settings
      end

      def defaults
        @defaults ||= settings["defaults"]
      end

      def api_key
        key = @config["key"] || settings["key"]
        return ENV.fetch(key[4..key.length - 1], nil) if key[0..3] == "ENV_"

        key
      end

      def authenticate
        unless api_key
          Jekyll.logger.warn "Action Network API Key not found."
          return
        end

        unless entry_point.dig("_links", "osdi:tags").present?
          Jekyll.logger.warn "Action Network Authentication Unsucessful"
          return
        end
        true
      end

      def client
        @client ||= ActionNetworkRest.new(api_key: api_key)
      end

      def entry_point
        @entry_point ||= client.entry_point.get
      end

      def page_size
        @page_size ||= @entry_point["max_page_size"]
      end

      def get_full_list(name, client = nil)
        client ||= @client
        page = 1
        actions = []
        loop do
          action_page = client.send(name).list(page: page)
          actions.concat(action_page)
          break if action_page.size < page_size

          page += 1
        end
        actions
      end
    end
  end
end
