# frozen_string_literal: true

require "action_network_rest"
require "jekyll"
require "yaml"
require "dotenv/load"

##
# This class is a Jekyll::Generator that creates collections from
# Action Network
module Jekyll
  ##
  # This sub class is a Jekyll::Generator that creates collections from
  # Action Network
  class ActionNetworkGenerator < Jekyll::Generator
    def generate(site)
      return unless site.config["action_network"]

      @site = site
      @log_name = "Action Network:"
      @settings ||= settings
      @config = site.config["action_network"]
      return unless authenticate

      @actions = Jekyll::Collection.new(site, "actions") if @config["actions"]
      @config.each do |name, _config|
        next unless @defaults[name]

        make_collection(name)
      end
      site.collections["actions"] = @actions if @actions
    end

    def settings
      @settings = YAML.load_file("#{File.expand_path(__dir__)}/settings.yaml")
      @defaults = @settings["defaults"]
      @fields = @settings["fields"]
      @filters = @settings["filters"]
      @settings
    end

    def make_collection(name)
      if @config[name].is_a?(Hash)
        config = @defaults[name].merge(@config[name])
        config["mappings"] = @defaults[name]["mappings"].merge(@config[name]["mappings"] || {})
      end
      config ||= @defaults[name]
      Jekyll.logger.info @log_name, "Processing #{name}"
      actions = get_full_list(name)
      Jekyll.logger.warn "#{name} before filter: #{actions.length}"
      filtered_actions = filter_actions(name, actions, config)
      Jekyll.logger.warn "#{name} after filter: #{filtered_actions.length}"
      collection = @site.collections[name] if @site.collections[name]
      collection ||= Jekyll::Collection.new(@site, config["collection"])
      filtered_actions.each do |action|
        slug = action["browser_url"].split("/")[-1]
        path = File.join(@site.source, "_#{config["collection"]}", "#{slug}.md")
        doc = Jekyll::Document.new(path, collection: collection, site: @site)
        doc.content = action[config["content"]]
        frontmattter_data = {}
        config["mappings"].each do |a, d|
          frontmattter_data[d] = action[a]
        end
        frontmattter_data.merge!({
                                   "layout" => config["layout"],
                                   "slug" => slug,
                                   "embed_code" => make_embed_code(action["browser_url"]),
                                   "action_type" => name
                                 })
        doc.merge_data!(frontmattter_data)
        collection.docs << doc
        @actions.docs << doc if @actions
      end
      @site.collections[config["collection"]] = collection
    end

    def make_embed_code(browser_url, style = nil)
      relative_url = browser_url.split("://")[1].sub("actionnetwork.org/", "")
      split_url = relative_url.split("/")
      css = @settings["embed"]["styles"][style] if style
      resource = @settings["embed"]["resources"][split_url[0]]
      slug = split_url[1]
      "#{css}<script src='https://actionnetwork.org/widgets/v5/#{resource}/#{slug}?format=js&source=widget'></script>
      <div id='can-#{resource}-area-#{slug}' style='width: 100%'></div>"
    end

    def get_full_list(name)
      page = 1
      actions = []
      loop do
        action_page = @client.send(name).list(page: page)
        break if action_page.empty?

        actions.concat(action_page)
        page += 1
      end
      actions
    end

    def filter_actions(name, actions, _config)
      public = []
      puts @filters["all"]
      puts @filters[name] || {}
      filters = @filters["all"].merge(@filters[name] || {})
      filters = filters.merge(@config["filters"] || {}) if @config.is_a? Hash
      puts filters
      actions.each do |action|
        filtered = true
        filters.each do |key, value|
          unless action[key] == value
            if value == "%" && action[key]
              filtered = false if action[key].length.positive?
            else
              Jekyll.logger.warn @log_name, "#{name} filtered because #{action[key]} == #{value}"
              filtered = true
              break
            end
          end
          filtered = false
        end
        public << reduce_fields(action) unless filtered
      end
      public
    end

    def reduce_fields(action)
      reduced_action = {}
      @fields.each do |field|
        reduced_action[field] = action[field] if action[field]
      end
      reduced_action
    end

    def get_api_key(key)
      return unless key
      return ENV.fetch(key[4..key.length - 1], nil) if key[0..3] == "ENV_"
      return ENV["ACTION_NETWORK_API_KEY"] if ENV["ACTION_NETWORK_API_KEY"]

      key
    end

    def authenticate
      api_key = get_api_key(@config["key"])
      Jekyll.logger.warn "Action Network API Key not found." unless api_key
      return unless api_key

      @client = ActionNetworkRest.new(api_key: api_key)
      unless @client.entry_point.authenticated_successfully?
        Jekyll.logger.warn "Action Network Authentication Unsucessful"
        return
      end
      true
    end
  end
end
