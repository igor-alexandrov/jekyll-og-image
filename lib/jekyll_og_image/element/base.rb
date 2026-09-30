# frozen_string_literal: true

class JekyllOgImage::Element::Base
  VALID_GRAVITY = %i[nw ne sw se].freeze

  private

  VALID_GRAVITY.each do |gravity|
    define_method("gravity_#{gravity}?") do
      @gravity == gravity
    end
  end

  def hex_to_rgb(input)
    case input
    when Array
      input
    when /\A#\h{3}\z/
      input[1..].chars.map { |digit| (digit * 2).hex }
    when /\A#\h{6}\z/
      input[1..].scan(/\h\h/).map(&:hex)
    else
      raise ArgumentError, "Invalid color #{input.inspect}, expected a hex color like \"#FFFFFF\" or \"#FFF\""
    end
  end

  def validate_gravity!
    unless VALID_GRAVITY.include?(@gravity)
      raise ArgumentError, "Invalid gravity: #{@gravity.inspect}"
    end
  end

  def calculate_ratio(image, width, height, mode)
    if mode == :min
      [ width.to_f / image.width, height.to_f / image.height ].min
    else
      [ width.to_f / image.width, height.to_f / image.height ].max
    end
  end

  def composite_with_gravity(canvas, overlay, x, y)
    x = canvas.width - overlay.width - x if gravity_ne? || gravity_se?
    y = canvas.height - overlay.height - y if gravity_sw? || gravity_se?

    canvas.composite(overlay, :over, x: [ x ], y: [ y ]).flatten
  end
end
