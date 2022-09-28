# frozen_string_literal: true

require "yaml"

module Jekyll
  module ActionNetwork
    ##
    # Some commonly used tools for the Action Network generator
    class Utils
      def settings
        return @settings if @settings

        @settings = YAML.load_file("#{File.expand_path(__dir__)}/settings.yaml")
        @defaults = @settings["defaults"]
        @fields = @settings["fields"]
        @filters = @settings["filters"]
        @settings
      end

      def make_embed_code(browser_url, style = nil)
        return unless browser_url

        relative_url = browser_url.split("://")[1].sub("actionnetwork.org/", "")
        split_url = relative_url.split("/")
        css = settings["embed"]["styles"][style] if style
        resource = settings["embed"]["resources"][split_url[0]]
        slug = split_url[1]
        "#{css}<script src='https://actionnetwork.org/widgets/v5/#{resource}/#{slug}?format=js&source=widget'></script>
        <div id='can-#{resource}-area-#{slug}' style='width: 100%'></div>"
      end
    end
  end
end
