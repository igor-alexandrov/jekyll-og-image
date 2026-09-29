# frozen_string_literal: true

require "test_helper"

class JekyllOgImage::Element::CanvasTest < Minitest::Test
  RED = [ 255, 0, 0 ].freeze

  def test_fills_background_color
    image = render(JekyllOgImage::Element::Canvas.new(200, 100, background_color: "#4285F4"))

    assert_equal [ 200, 100 ], [ image.width, image.height ]
    assert_equal [ 66, 133, 244 ], rgb_at(image, 0, 0)
    assert_equal [ 66, 133, 244 ], rgb_at(image, 199, 99)
  end

  def test_background_image_covers_canvas
    # A square image on a 2:1 canvas is scaled up until it covers the full width
    canvas = JekyllOgImage::Element::Canvas.new(200, 100, background_image: solid_png(50, 50, RED))
    image = render(canvas)

    assert_equal [ 200, 100 ], [ image.width, image.height ]
    assert_equal RED, rgb_at(image, 0, 0)
    assert_equal RED, rgb_at(image, 199, 99)
  end

  def test_drawing_methods_are_chainable
    canvas = JekyllOgImage::Element::Canvas.new(200, 100)

    assert_same canvas, canvas.text("Hi", dpi: 72)
    assert_same canvas, canvas.border(10)
    assert_same canvas, canvas.image(solid_png(10, 10, RED), width: 10, height: 10, radius: nil)
  end

  private

  def render(canvas)
    Dir.mktmpdir do |dir|
      path = File.join(dir, "canvas.png")
      canvas.save(path)
      Vips::Image.new_from_file(path, access: :sequential).copy_memory
    end
  end
end
