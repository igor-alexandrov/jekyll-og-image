# frozen_string_literal: true

class JekyllOgImage::Element::Border < JekyllOgImage::Element::Base
  class Part < Data.define(:rgb, :width, :height, :offset)
  end

  def initialize(size, position: :bottom, fill: "#000000")
    @size = size
    @position = position
    @fill = Array(fill)

    validate_position!
  end

  def apply_to(canvas, &block)
    border = Vips::Image.black(*dimensions(canvas))

    parts(canvas).each do |part|
      image = Vips::Image.black(part.width, part.height).ifthenelse([ 0, 0, 0 ], part.rgb)
      x, y = vertical? ? [ 0, part.offset ] : [ part.offset, 0 ]

      border = border.composite(image, :over, x: [ x ], y: [ y ]).flatten
    end

    result = block.call(canvas, border) if block_given?

    x, y = result ? [ result.fetch(:x, 0), result.fetch(:y, 0) ] : [ 0, 0 ]

    if vertical?
      x = @position == :left ? x : canvas.width - @size - x
      canvas.composite(border, :over, x: [ x ], y: [ 0 ]).flatten
    else
      y = @position == :top ? y : canvas.height - @size - y
      canvas.composite(border, :over, x: [ 0 ], y: [ y ]).flatten
    end
  end

  private

  def hex_to_rgb(hex)
    hex.match(/#(..)(..)(..)/)[1..3].map { |x| x.hex }
  end

  def dimensions(canvas)
    if vertical?
      [ @size, canvas.height ]
    else
      [ canvas.width, @size ]
    end
  end

  def parts(canvas)
    length = vertical? ? canvas.height : canvas.width

    @fill.map.with_index do |color, index|
      # Stripe edges are rounded down, so the last stripe absorbs any remainder
      from = length * index / @fill.size
      to = length * (index + 1) / @fill.size
      width, height = vertical? ? [ @size, to - from ] : [ to - from, @size ]

      Part.new(rgb: hex_to_rgb(color), width: width, height: height, offset: from)
    end
  end

  def vertical?
    @position == :left || @position == :right
  end

  def validate_position!
    unless %i[left right top bottom].include?(@position)
      raise ArgumentError, "Invalid position: #{@position.inspect}"
    end
  end
end
