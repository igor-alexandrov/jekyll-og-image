# frozen_string_literal: true

class JekyllOgImage::Element::Text < JekyllOgImage::Element::Base
  def initialize(message, gravity: :nw, width: nil, dpi: nil, color: "#000000", font: nil)
    @message = message
    @gravity = gravity
    @width = width
    @dpi = dpi
    @color = color
    @font = font

    validate_gravity!
  end

  def apply_to(canvas, &block)
    text = Vips::Image.text(@message,
      font: @font,
      width: @width,
      dpi: @dpi,
      wrap: :word,
      align: :low
    )

    text = text
      .new_from_image(hex_to_rgb(@color))
      .copy(interpretation: :srgb)
      .bandjoin(text)

    result = block.call(canvas, text) if block_given?

    x, y = result ? [ result.fetch(:x, 0), result.fetch(:y, 0) ] : [ 0, 0 ]

    composite_with_gravity(canvas, text, x, y)
  end

  private

  VALID_GRAVITY.each do |gravity|
    define_method("gravity_#{gravity}?") do
      @gravity == gravity
    end
  end
end
