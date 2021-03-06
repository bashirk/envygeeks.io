# Frozen-string-literal: true
# Copyright: 2016 - 2017 - MIT License
# Encoding: utf-8

def docker?
  File.file?("/.dockerenv")
end

source "https://rubygems.org"
gem "jekyll", "~> 3.6", require: false
gem "uglifier", "~> 4.0", require: false
gem "sprockets", "~> 4.0.beta", require: false
gem "liquid-hash-or-array-drop", "~> 1.0", require: false
gem "mini_magick", "~> 4.8", require: false
gem "nokogiri", "~> 1.8", require: false
gem "babel-transpiler", require: false
gem "octokit", require: false
gem "sassc", require: false
gem "bootstrap", require: false
gem "rake", require: false

unless docker?
  gem "mini_racer", {
    require: false,
  }
end

# --
# Testing
# --
group :test do
  gem "rspec", "~> 3.6", require: false
  gem "luna-rspec-formatters", "~> 3.7", require: false
  gem "html-proofer", "~> 3.7", require: false
  gem "rubocop", "0.52", require: false
end

# --
# Plugins
# --
group :jekyll_plugins do
  gem "jekyll-sanity", "~> 1.0"
  gem "jekyll-posts_by_year", "~> 1.0"
  gem "jekyll-post-tags", "~> 1.0"
  gem "jekyll-cache", "~> 1.0"

  # --
  # Locally I prefer to work my version since I tend to do
  #   manual QA and debugging with my own site which is the
  #   defacto example of Jekyll-Assets at it's basic.
  # --
  gem "jekyll-sync", path: "gems/jekyll-sync"
  gem "jekyll-metadata", path: "gems/jekyll-metadata"
  gem "jekyll-assets", docker? || ENV["CI"] == "true" ?
    { git:  "https://github.com/envygeeks/jekyll-assets" } :
    { path: "~/development/EnvyGeeks/Jekyll-Assets" }

  # --
  # Non-CI Plugins
  # --
  unless ENV["CI"] == "true"
    group :development do
      gem "jekyll-reload", docker? ?
        { git: "https://github.com/anomaly/jekyll-reload" } :
        { path: "~/Development/Anomaly/Jekyll-Reload" }
    end
  end
end

# --
# Non-CI Development
# --
unless ENV["CI"] == "true"
  group :development do
    gem "travis", require: false
    gem "pry", require: false
  end
end
