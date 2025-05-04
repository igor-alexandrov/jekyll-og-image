# frozen_string_literal: true

# require "anyway_config"

class JekyllOgImage::Configuration
  Canvas = Data.define(:background_color, :background_image) do
    def initialize(background_color: "#FFFFFF", background_image: nil)
      super
    end
  end

  Header = Data.define(:font_family, :color) do
    def initialize(font_family: "Helvetica, Bold", color: "#2f313d")
      super
    end
  end

  Content = Data.define(:font_family, :color) do
    def initialize(font_family: "Helvetica, Regular", color: "#535358")
      super
    end
  end

  Border = Data.define(:width, :fill) do
    def initialize(width: 0, fill: nil)
      fill.is_a?(Array) ? fill : [ fill ]
      super(width: width, fill: fill)
    end
  end

  def initialize(raw_config)
    @raw_config = raw_config
  end

  def merge!(other)
    config = Jekyll::Utils.deep_merge_hashes(
      @raw_config,
      other.to_h
    )

    self.class.new(config)
  end

  def to_h
    @raw_config
  end

  def ==(other)
    to_h == other.to_h
  end

  def collections
    @raw_config["collections"] || [ "posts" ]
  end

  def output_dir
    @raw_config["output_dir"] || "assets/images/og"
  end

  def force?
    @raw_config["force"].nil? ? false : @raw_config["force"]
  end

  def verbose?
    @raw_config["verbose"].nil? ? false : @raw_config["verbose"]
  end

  def skip_drafts?
    @raw_config["skip_drafts"].nil? ? true : @raw_config["skip_drafts"]
  end

  def canvas
    @raw_config["canvas"] ? Canvas.new(**Jekyll::Utils.symbolize_hash_keys(@raw_config["canvas"])) : Canvas.new
  end

  def header
    @raw_config["header"] ? Header.new(**Jekyll::Utils.symbolize_hash_keys(@raw_config["header"])) : Header.new
  end

  def content
    @raw_config["content"] ? Content.new(**Jekyll::Utils.symbolize_hash_keys(@raw_config["content"])) : Content.new
  end

  def image
    @raw_config["image"]
  end

  def domain
    @raw_config["domain"]
  end

  def border_bottom
    @raw_config["border_bottom"] ? Border.new(**Jekyll::Utils.symbolize_hash_keys(@raw_config["border_bottom"])) : nil
  end

  def margin_bottom
    80 + (border_bottom&.width || 0)
  end
end
