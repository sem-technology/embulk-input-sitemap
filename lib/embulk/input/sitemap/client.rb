require "ostruct"
require "open-uri"
require "nokogiri"
require "zlib"
module Embulk
  module Input
    module Sitemap
      class Client
        def initialize(url, params)
          @url = url
          @params = params
        end

        def query
          queries = @params.map{|param| "#{param["name"]}=#{param["value"]}"}
          return "?" + queries.join("&") if queries.length > 0 and @url.include?("?") == false
          return "&" + queries.join("&") if queries.length > 0 and @url.include?("?")
          return ""
        end

        def invoke
          items = []
          Embulk.logger.info "GET #{@url}#{self.query}"
          response = open(@url + self.query) do |f|
            Embulk.logger.info "Content-Type = #{f.content_type}"
            case f.content_type
              when "application/x-gzip", "application/octet-stream" then
                `curl #{@url} | gunzip -d`
              else f.read
            end
          end
          document = Nokogiri::XML(response)
          sitemaps = document.css("sitemap")
          urls = document.css("url")
          Embulk.logger.info "Find #{sitemaps.length} sitemaps, #{urls.length} urls"
          if sitemaps.length > 0
            items << sitemaps.collect do |sitemap|
              Client.new(sitemap.css("loc").first.text.to_s).invoke
            end
          end
          if urls.length > 0
            items << urls.collect do |url|
              item = {}
              item[:loc] = url.css("loc").first.text.to_s
              item[:changefreq] = url.css("changefreq").first.text.to_s if url.css("changefreq").first
              item[:priority] = url.css("priority").first.text.to_s if url.css("priority").first
              item[:lastmod] = url.css("lastmod").first.text.to_s if url.css("lastmod").first
              OpenStruct.new(item)
            end
          end
          items.flatten
        end
      end
    end
  end
end
