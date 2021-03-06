# Frozen-String-Literal: true
# Copyright 2016 - 2017 Jordon Bedwell - MIT License
# Encoding: UTF-8

require "addressable"
module EnvyGeeks
  module Filters
    extend Forwardable::Extended
    rb_delegate :config, to: :site
    rb_delegate :site, to: "@context.registers", type: :hash
    rb_delegate :data, to: :site

    # --
    def strip(txt)
      unless txt.is_a?(String)
        return txt
      end

      txt.strip
    end

    # --
    # Allows you to output the class.
    # @note this exists because Jekyll & Liquid have terrible debugging.
    # @note this is seriously for debugging only.
    # @return [String] the class name.
    # --
    def klass(obj)
      obj.class.to_s
    end

    # --
    # Allows you to extract the keys.
    # @param obj [Array,Hash] the array or hash to key
    # @return [Array] the keys
    # --
    def keys(obj)
      return obj if obj.is_a?(Array)
      unless obj.is_a?(Hash)
        raise ArgumentError, "must be a hash or array"
      end

      obj.keys
    end

    # --
    # Allows you to extract the values.
    # @param obj [Array,Hash] the array or hash to value
    # @return [Array] the values
    # --
    def vals(obj)
      return obj if obj.is_a?(Array)
      unless obj.is_a?(Hash)
        raise ArgumentError, "must be a hash or array"
      end

      obj.values
    end

    # --
    # Allows you to reverse an array.
    # @param ary [Array] the array to reverse.
    # @return [Array] the reversed array.
    # --
    def reverse(ary)
      unless ary.is_a?(Array)
        raise ArgumentError, "must be an array"
      end

      ary.reverse
    end

    # --
    # Reverse, Reverse and organize by waterfall.
    # rubocop:disable Metrics/CyclomaticComplexity
    # @param array [Array] the array to turn into a waterfall.
    # @param posts [true|false] are they posts?
    # @return the waterfalled array
    # --
    def waterfall(object)
      unless object.is_a?(Array) && !object.is_a?(Hash)
        raise ArgumentError, "must be an Array or Hash of Array"
      end

      if object.is_a?(Hash)
        return object.each do |k, v|
          object[k] = waterfall(v)
        end
      end

      one, two = [], []
      return object if object.size == 1
      object.sort_by { |v| v.respond_to?(:size) ? v.size : v["title"].size }
        .each_with_index { |v, i| i.odd? ? one.unshift(v) : two.push(v) }

      two | one
    end

    # --
    # Deal with dates in a clean way.
    # @param doc [Jekyll::Document] the document to get the date from.
    # @return [String] the formatted `DateTime`.
    # --
    def modified_or_xmldate(doc)
      return date_to_xmlschema(doc["date"]) if doc["date"]
      path = @context.registers[:site].in_source_dir(doc["path"])
      return date_to_xmlschema(File.stat(path).mtime) if File.exist?(path)
      date_to_xmlschema(Time.now)
    end

    # --
    # Build a canoical URL for the current page.
    # @param [<Anything>] page the page object to work on.
    # @return [String]
    # --
    def canonical_url(page)
      url = page.respond_to?(:url) ? page.url : page["url"]
      url = base_prefix + url

      return url if url == "/"
      return "/" if url == ""

      url.gsub(%r!\.html$!, "")
        .gsub(%r!(?<\!http:|https:)/{2}!, "/")
        .gsub(%r!/$!, "")
    end

    # --
    # Strip the ".html" and "/" from a URL
    # @param url [String] the string you wish to make pretty.
    # @return [String] the prettified url.
    # --
    def pretty(url)
      url.to_s.gsub(%r!/$!, "")
        .gsub(%r!\.html$!, "")
    end

    # --
    # Ordanalized time, st, nd.
    # @param time [DateTime] the date time.
    # @param archive [true|false] whether this is for the archive.
    # @return [String] the time string ordinalized.
    # rubocop:disable Metrics/PerceivedComplexity
    # rubocop:disable Style/FormatStringToken
    # --
    def ordinalize(time)
      return "" unless time.is_a?(DateTime) || time.is_a?(Time)
      day = time.strftime("%d")

      tsx = "st" if day.end_with?("1")
      tsx = "nd" if day.end_with?("2")
      tsx = "rd" if day.end_with?("3")
      tsx = "th" if day.end_with?("4", "5")
      tsx = "th" if day.between?("11", "20")
      time.strftime("%A, %B %d#{tsx}, %Y")
    end

    # --
    # Markdownify a string.
    # This allows me to makdownify titles.
    # @param string [String] the string to markdownify.
    # @return [String]
    # --
    def markdownify_title(string)
      return "" unless string.is_a?(String)
      raise ArgumentError, "invalid input" if string =~ %r!\n{2}!
      method = Jekyll::Filters.instance_method(:markdownify).bind(self)
      method.call(string).gsub(%r!</?p>!, "")
    end

    # --
    # Get the base URL.
    # --
    private
    def base_prefix
      port = config["port"]
      serving = config["serving"]
      dev  = Jekyll.env == "development"
      ssl  = data["site"]["ssl"]
      base = site.baseurl

      host = dev ? "localhost" : data["site"]["hostname"]
      proto = config["force-ssl"] || (!dev && ssl) ? "https" : "http"
      return format("%s://%s/%s:%s", proto, host, base, port) if serving && base
      return format("%s://%s:%s", proto, host, port) if serving
      format("%s://%s/%s", proto, host, base)
    end
  end
end

# --
Liquid::Template.register_filter(EnvyGeeks::Filters)
