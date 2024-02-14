# frozen_string_literal: true

require "vips"

class JekyllOgImage::Element::Canvas < JekyllOgImage::Element::Base
  def initialize(width, height, background_color: "#ffffff", background_image: nil)
    @canvas = Vips::Image.black(width, height).ifthenelse([ 0, 0, 0 ], hex_to_rgb(background_color))

    if background_image
      overlay = Vips::Image.new_from_buffer(background_image, "")

      ratio = calculate_ratio(overlay, width, height, :max)
      overlay = overlay.resize(ratio)

      @canvas = @canvas.composite(overlay, :over, x: [ 0 ], y: [ 0 ]).flatten
    end

    @canvas
  end

  def image(source, **opts, &block)
    image = JekyllOgImage::Element::Image.new(source, **opts)
    @canvas = image.apply_to(@canvas, &block)

    self
  end

  def text(message, **opts, &block)
    text = JekyllOgImage::Element::Text.new(message, **opts)
    @canvas = text.apply_to(@canvas, &block)

    self
  end

  def border(width, **opts, &block)
    border = JekyllOgImage::Element::Border.new(width, **opts)
    @canvas = border.apply_to(@canvas, &block)

    self
  end

  def save(filename)
    @canvas.write_to_file(filename)
  end
end
