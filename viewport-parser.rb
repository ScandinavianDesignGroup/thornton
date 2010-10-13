require 'nokogiri'
require 'open-uri'

class ViewportParser
  class Doc < Nokogiri::XML::SAX::Document
    attr_accessor :viewport

    def start_element(name, attributes = [])
      case name
      when 'meta'
        h = Hash[*attributes]
        if h["name"] == "viewport"
          @viewport ||= h["content"]
        end
      end
    end
  end

  UserAgent = "Mozilla/5.0 (iPhone; U; CPU iPhone OS 3_1_3 like Mac OS X; en-us) AppleWebKit/528.18 (KHTML, like Gecko) Version/4.0 Mobile/7E18 Safari/528.16"

  def initialize(url)
    @url = url
  end

  def parse
    doc = Doc.new
    begin
      parser = Nokogiri::HTML::SAX::Parser.new(doc)
      parser.parse(open(@url, "User-Agent" => UserAgent))
    rescue
    end
    doc
  end
end

