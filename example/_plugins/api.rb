require 'jekyll/generator'
require 'jekyll/page_without_a_file'
require 'json'

module JsonPages
    class JsonPages <  ::Jekyll::Generator

        def json_collection(site, collection_name)
            collection_json = []
            site.collections[collection_name].docs.each do |item|
                json_file = Jekyll::PageWithoutAFile.new(site, "", "api/#{collection_name}/#{item.basename_without_ext}", "index.json")
                json_file.content = JSON.generate(item.data)
                collection_json << item.data.merge!({
                    "url": item.url
                })
                site.pages << json_file
            end
            collection_json
        end

        def generate(site)
            collections_json = {}
            site.collections.each do |name, collection|
                json_collection = json_collection(site, name)
                json_collection_page = Jekyll::PageWithoutAFile.new(site, "", "api/#{name}", "index.json")
                json_collection_page.content = JSON.generate(json_collection)
                site.pages << json_collection_page
                collections_json[name] = collection.metadata
            end
            root_file = Jekyll::PageWithoutAFile.new(site, "", "api", "index.json")
            root_file.content = JSON.generate(collections_json)
            site.pages << root_file
        end
    end
end