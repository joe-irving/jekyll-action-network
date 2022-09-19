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
      end

      def make_collections
        @config["import"].each do |config|
          name = config["name"] if config.is_a? Hash
          name ||= config if config.is_a? String
          next unless name

          make_collection(name, config)
        end
        @site.collections["actions"] = actions if @config["actions"]
      end

      def make_collection(name, config)
        return unless defaults[name]

        collection = Jekyll::ActionNetwork::Collection.new(@site, @client, config, settings)
        @site.collections[collection.config["collection"]] = collection.populate
        actions.docs.concat(collection.collection.docs)
      end

      def actions
        return @actions if @actions

        actions_config = @config["actions"] if @config["actions"].is_a? Hash
        actions_settings = @settings["actions"].merge(actions_config || {})
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

      private

      def api_key
        key = @config["key"] || @settings["key"]
        return ENV.fetch(key[4..key.length - 1], nil) if key[0..3] == "ENV_"

        key
      end

      def authenticate
        unless api_key
          Jekyll.logger.warn "Action Network API Key not found."
          return
        end

        @client = ActionNetworkRest.new(api_key: api_key)
        unless @client.entry_point.authenticated_successfully?
          Jekyll.logger.warn "Action Network Authentication Unsucessful"
          return
        end
        true
      end
    end
  end
end
