# frozen_string_literal: true

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
      super(width: width, fill: Array(fill || "#000000"))
    end
  end

  Image = Data.define(:path, :width, :height, :radius, :position, :gravity) do
    def initialize(path: nil, width: 150, height: 150, radius: 50, position: {}, gravity: :ne)
      # Values read from YAML have string keys and string gravity
      position = { x: 80, y: 100 }.merge(position.transform_keys(&:to_sym))

      super(path: path, width: width, height: height, radius: radius, position: position, gravity: gravity.to_sym)
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

  def merge(other)
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
    build_section(Canvas, "canvas")
  end

  def header
    build_section(Header, "header")
  end

  def content
    build_section(Content, "content")
  end

  def image
    # Legacy support: if image is just a string, convert it to the new format
    return Image.new(path: @raw_config["image"]) if @raw_config["image"].is_a?(String)

    build_section(Image, "image")
  end

  def domain
    @raw_config["domain"]
  end

  def border_bottom
    build_section(Border, "border_bottom") if @raw_config["border_bottom"]
  end

  def metadata
    build_section(Metadata, "metadata")
  end

  private

  def build_section(klass, name)
    value = @raw_config[name]
    return klass.new unless value

    unless value.is_a?(Hash)
      raise Jekyll::Errors::InvalidConfigurationError, "og_image.#{name} must be a set of options, got #{value.inspect}"
    end

    options = Jekyll::Utils.symbolize_hash_keys(value)
    unknown = options.keys - klass.members

    if unknown.any?
      raise Jekyll::Errors::InvalidConfigurationError,
        "Unknown og_image.#{name} option: #{unknown.join(", ")}. Valid options: #{klass.members.join(", ")}"
    end

    klass.new(**options)
  end
end
