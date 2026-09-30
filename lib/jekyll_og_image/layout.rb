# frozen_string_literal: true

# Positions and sizes for an image. Everything, including the pixel sizes in the
# configuration (logo, border), is designed for a 1200px-wide canvas and scaled
# with the canvas width, so any canvas size keeps the same proportions.
class JekyllOgImage::Layout
  REFERENCE_WIDTH = 1200.0

  def initialize(config)
    @config = config
    @scale = config.canvas.width / REFERENCE_WIDTH
  end

  # Left, right and bottom margin
  def margin
    scaled(80)
  end

  def header_top
    scaled(100)
  end

  def header_dpi
    scaled(400)
  end

  def content_dpi
    scaled(150)
  end

  # Space between the header and whatever is next to or below it
  def gap
    scaled(30)
  end

  def border_width
    scaled(@config.border_bottom&.width || 0)
  end

  # Distance from the bottom edge to the metadata line, above the border
  def bottom
    margin + border_width
  end

  def logo_width
    scaled(@config.image.width)
  end

  def logo_height
    scaled(@config.image.height)
  end

  def logo_radius
    scaled(@config.image.radius) if @config.image.radius
  end

  def logo_position
    { x: scaled(@config.image.position[:x]), y: scaled(@config.image.position[:y]) }
  end

  def content_width
    @config.canvas.width - 2 * margin
  end

  # Leaves room for the logo next to the header
  def header_width
    @config.image.path ? content_width - logo_width - gap : content_width
  end

  # How tall the header can be without reaching the metadata line
  def header_max_height(metadata_line_height)
    @config.canvas.height - header_top - bottom - metadata_line_height - gap
  end

  private

  def scaled(value)
    (value * @scale).round
  end
end
