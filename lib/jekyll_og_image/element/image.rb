# frozen_string_literal: true

class JekyllOgImage::Element::Image < JekyllOgImage::Element::Base
  def initialize(canvas, source, gravity: :nw, width:, height:)
    @canvas = canvas
    @gravity = gravity
    @source = source
    @width = width
    @height = height

    validate_gravity!
  end

  def apply(&block)
    image = Vips::Image.new_from_buffer(@source, "")
    result = block.call(@canvas, image) if block_given?

    if @width && @height
      ratio = calculate_ratio(image, @width, @height, :min)
      image = image.resize(ratio)
    end

    x, y = result ? [ result.fetch(:x, 0), result.fetch(:y, 0) ] : [ 0, 0 ]

    if gravity_nw?
      @canvas.composite(image, :over, x: [ x ], y: [ y ]).flatten
    elsif gravity_ne?
      x = @canvas.width - image.width - x
      @canvas.composite(image, :over, x: [ x ], y: [ y ]).flatten
    elsif gravity_sw?
      y = @canvas.height - image.height - y
      @canvas.composite(image, :over, x: [ x ], y: [ y ]).flatten
    elsif gravity_se?
      x = @canvas.width - image.width - x
      y = @canvas.height - image.height - y
      @canvas.composite(image, :over, x: [ x ], y: [ y ]).flatten
    end
  end

  private

  VALID_GRAVITY.each do |gravity|
    define_method("gravity_#{gravity}?") do
      @gravity == gravity
    end
  end

  def calculate_ratio(image, width, height, mode)
    if mode == :min
      [ width.to_f / image.width, height.to_f / image.height ].min
    else
      [ width.to_f / image.width, height.to_f / image.height ].max
    end
  end
end
