# frozen_string_literal: true

# require "anyway_config"

class JekyllOgImage::Configuration
  Canvas = Data.define(:background_color, :background_image, :width, :height) do
    def initialize(background_color: "#FFFFFF", background_image: nil, width: 1200, height: 600)
      super
    end
  end

  Header = Data.define(:font_family, :color, :prefix, :suffix) do
    def initialize(font_family: "Helvetica, Bold", color: "#2f313d", prefix: "", suffix: "")
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

  Image = Data.define(:path, :width, :height, :radius, :position, :gravity) do
    def initialize(path: nil, width: 150, height: 150, radius: 50, position: { x: 80, y: 100 }, gravity: :ne)
      super
    end
  end

  Metadata = Data.define(:fields, :separator, :date_format) do
    def initialize(fields: [ "date", "tags" ], separator: " • ", date_format: "%B %d, %Y")
      super
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

  def enabled?
    @raw_config["enabled"].nil? ? true : @raw_config["enabled"]
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
    if @raw_config["image"].is_a?(String)
      # Legacy support: if image is just a string, convert it to the new format
      Image.new(path: @raw_config["image"])
    elsif @raw_config["image"]
      Image.new(**Jekyll::Utils.symbolize_hash_keys(@raw_config["image"]))
    else
      Image.new
    end
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


  def metadata
    @raw_config["metadata"] ? Metadata.new(**Jekyll::Utils.symbolize_hash_keys(@raw_config["metadata"])) : Metadata.new
  end
end
