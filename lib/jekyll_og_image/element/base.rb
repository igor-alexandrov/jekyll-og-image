# frozen_string_literal: true

class JekyllOgImage::Element::Base
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
end
