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
end
