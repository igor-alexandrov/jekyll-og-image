# frozen_string_literal: true

class JekyllOgImage::Element::Image < JekyllOgImage::Element::Base
  def initialize(source, gravity: :nw, width:, height:, radius:)
    @gravity = gravity
    @source = source
    @width = width
    @height = height
    @radius = radius

    validate_gravity!
  end

  def apply_to(canvas, &block)
    image = Vips::Image.new_from_buffer(@source, "")
    image = round_corners(image) if @radius

    result = block.call(canvas, image) if block_given?

    if @width && @height
      ratio = calculate_ratio(image, @width, @height, :min)
      image = image.resize(ratio)
    end

    x, y = result ? [ result.fetch(:x, 0), result.fetch(:y, 0) ] : [ 0, 0 ]

    composite_with_gravity(canvas, image, x, y)
  end

  private

  VALID_GRAVITY.each do |gravity|
    define_method("gravity_#{gravity}?") do
      @gravity == gravity
    end
  end

  def round_corners(image)
    mask = %(
      <svg viewBox="0 0 #{image.width} #{image.height}">
        <rect
          rx="#{@radius}"
          ry="#{@radius}"
          x="0"
          y="0"
          width="#{image.width}"
          height="#{image.height}"
          fill="#fff"
        />
      </svg>
    )

    mask = Vips::Image.new_from_buffer(mask, "")
    image.bandjoin mask[3]
  end

  def calculate_ratio(image, width, height, mode)
    if mode == :min
      [ width.to_f / image.width, height.to_f / image.height ].min
    else
      [ width.to_f / image.width, height.to_f / image.height ].max
    end
  end
end
