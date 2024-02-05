# frozen_string_literal: true

require "vips"

class JekyllOgImage::Element::Canvas < JekyllOgImage::Element::Base
  def initialize(width, height, color: "#ffffff")
    @canvas = Vips::Image.black(width, height).ifthenelse([ 0, 0, 0 ], hex_to_rgb(color))
  end

  def image(source, **opts, &block)
    image = JekyllOgImage::Element::Image.new(
      @canvas, source, **opts
    )

    @canvas = image.apply(&block)

    self
  end

  def text(message, **opts, &block)
    text = JekyllOgImage::Element::Text.new(
      @canvas, message, **opts
    )

    @canvas = text.apply(&block)

    self
  end

  def border(width, position: :bottom, fill: "#000000")
    @canvas = JekyllOgImage::Element::Border.new(
      @canvas, width,
      position: position,
      fill: fill
    ).apply

    self
  end

  def save(filename)
    @canvas.write_to_file(filename)
  end
end
