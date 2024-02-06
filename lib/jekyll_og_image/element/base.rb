# frozen_string_literal: true

class JekyllOgImage::Element::Base
  VALID_GRAVITY = %i[nw ne sw se].freeze

  private

  def hex_to_rgb(input)
    case input
    when String
      input.match(/#(..)(..)(..)/)[1..3].map(&:hex)
    when Array
      input
    else
      raise ArgumentError, "Unknown input #{input.inspect}"
    end
  end

  def validate_gravity!
    unless VALID_GRAVITY.include?(@gravity)
      raise ArgumentError, "Invalid gravity: #{@gravity.inspect}"
    end
  end

  def composite_with_gravity(canvas, overlay, x, y)
    if gravity_nw?
      canvas.composite(overlay, :over, x: [ x ], y: [ y ]).flatten
    elsif gravity_ne?
      x = canvas.width - overlay.width - x
      canvas.composite(overlay, :over, x: [ x ], y: [ y ]).flatten
    elsif gravity_sw?
      y = canvas.height - overlay.height - y
      canvas.composite(overlay, :over, x: [ x ], y: [ y ]).flatten
    elsif gravity_se?
      x = canvas.width - overlay.width - x
      y = canvas.height - overlay.height - y
      canvas.composite(overlay, :over, x: [ x ], y: [ y ]).flatten
    end
  end
end
