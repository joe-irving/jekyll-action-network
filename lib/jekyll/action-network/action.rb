# frozen_string_literal: true

module Jekyll
  module ActionNetwork
    ##
    # An action network action, call the +doc+ method to get a
    # Jekyll::Document for this action
    class Action
      def initialize(site, name, collection, config, action, settings)
        @site = site
        @collection = collection
        @config = config
        @action = action
        @name = name
        @settings = settings
        @utils = Jekyll::ActionNetwork::Utils.new
      end

      def doc
        return @doc if @doc

        @doc = Jekyll::Document.new(path, collection: @collection, site: @site)
        @doc.content = content
        @doc.merge_data!(front_matter)
        @doc
      end

      def slug
        @slug ||= @action["browser_url"].split("/")[-1] if @action["browser_url"]
      end

      def path
        @path ||= File.join(@site.source, "_#{@config["collection"]}", "#{slug}.md")
      end

      def front_matter
        return @front_matter if @front_matter

        @front_matter = {}
        @config["mappings"].each do |a, d|
          front_matter[d] = @action[a]
        end
        @front_matter["layout"] = @config["layout"]
        @front_matter["slug"] = slug
        @front_matter["embed_code"] = @utils.make_embed_code(@action["browser_url"])
        @front_matter["action_type"] = @name
        @front_matter["action_network_endpoint"] = endpoint
        @front_matter["action_network_blindpost"] = blindpost
        @front_matter
      end

      def endpoint
        @action['_links']['self']['href']
      end

      def blindpost
        linked_type = @settings['endpoint_mappings'][@name]
        return @action['_links']["osdi:#{linked_type}"]['href'] if linked_type
      end

      def content
        @content ||= @action[@config["content"]]
      end
    end
  end
end
