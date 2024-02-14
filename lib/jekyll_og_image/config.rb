# frozen_string_literal: true

require "anyway_config"

class JekyllOgImage::Config < Anyway::Config
  attr_config output_dir: "assets/images/og"
  attr_config force: false
  attr_config verbose: false
  attr_config canvas: {
    background_color: "#FFFFFF",
    background_image: nil
  }
  attr_config header: {
    font_family: "Helvetica, Bold",
    color: "#2f313d"
  }
  attr_config content: {
    font_family: "Helvetica, Regular",
    color: "#535358"
  }
  attr_config :image
  attr_config :domain
  attr_config :border_bottom

  coerce_types canvas: {
    background_color: { type: :string },
    background_image: { type: :string }
  }

  coerce_types header: {
    font_family: { type: :string },
    color: { type: :string }
  }

  coerce_types content: {
    font_family: { type: :string },
    color: { type: :string }
  }

  coerce_types image: { type: :string }

  coerce_types border_bottom: {
    width: { type: :integer },
    fill: { type: :string, array: true }
  }

  def margin_bottom
    80 + (border_bottom&.fetch("width", 0) || 0)
  end
end
