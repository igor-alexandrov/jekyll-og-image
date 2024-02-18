# frozen_string_literal: true

module JekyllOgImage
end

require "zeitwerk"
loader = Zeitwerk::Loader.for_gem
loader.ignore("#{__dir__}/jekyll-og-image.rb")
loader.setup
loader.eager_load

module JekyllOgImage
  def self.config
    @config ||= JekyllOgImage::Configuration.new({})
  end

  def self.config=(config)
    @config = config
  end
end

Jekyll::Hooks.register(:site, :after_init) do |site|
  JekyllOgImage.config = JekyllOgImage::Configuration.new(site.config["og_image"] || {})
end
