# frozen_string_literal: true

require "test_helper"

class JekyllOgImage::Element::ImageTest < Minitest::Test
  WHITE = [ 255, 255, 255 ].freeze
  RED = [ 255, 0, 0 ].freeze

  def setup
    @canvas = solid_image(200, 100, WHITE)
  end

  def test_nw_gravity
    image = apply(gravity: :nw) { { x: 10, y: 5 } }

    assert_placed_at image, left: 10, top: 5
  end

  def test_ne_gravity
    image = apply(gravity: :ne) { { x: 10, y: 5 } }

    assert_placed_at image, left: 200 - 10 - 20, top: 5
  end

  def test_sw_gravity
    image = apply(gravity: :sw) { { x: 10, y: 5 } }

    assert_placed_at image, left: 10, top: 100 - 5 - 20
  end

  def test_se_gravity
    image = apply(gravity: :se) { { x: 10, y: 5 } }

    assert_placed_at image, left: 200 - 10 - 20, top: 100 - 5 - 20
  end

  def test_scales_to_fit_within_width_and_height
    # 40x20 fitted into 20x20 keeps its aspect ratio: 20x10
    image = apply(source: solid_png(40, 20, RED), width: 20, height: 20)

    assert_equal [ 0, 0, 20, 10 ], image.find_trim(background: WHITE, threshold: 10)
  end

  def test_rounds_corners
    image = apply(source: solid_png(40, 40, RED), width: 40, height: 40, radius: 10)

    assert_equal WHITE, rgb_at(image, 0, 0)
    assert_equal WHITE, rgb_at(image, 39, 39)
    assert_equal RED, rgb_at(image, 20, 20)
    assert_equal RED, rgb_at(image, 20, 0)
  end

  def test_corner_radius_does_not_depend_on_source_size
    small = apply(source: solid_png(40, 40, RED), width: 40, height: 40, radius: 10)
    large = apply(source: solid_png(400, 400, RED), width: 40, height: 40, radius: 10)

    # A 10px radius cuts ~3px deep along the diagonal
    assert_equal WHITE, rgb_at(large, 1, 1)
    assert_equal RED, rgb_at(large, 4, 4)
    assert_equal (small - large).abs.max, 0
  end

  def test_accepts_source_with_alpha_channel
    source = solid_image(20, 20, RED).bandjoin(255).write_to_buffer(".png")
    image = apply(source: source)

    assert_equal 3, image.bands
    assert_equal RED, rgb_at(image, 10, 10)
  end

  def test_rejects_invalid_gravity
    assert_raises(ArgumentError) do
      JekyllOgImage::Element::Image.new(solid_png(20, 20, RED), gravity: :center, width: 20, height: 20, radius: nil)
    end
  end

  private

  def apply(source: solid_png(20, 20, RED), gravity: :nw, width: 20, height: 20, radius: nil, &block)
    element = JekyllOgImage::Element::Image.new(source, gravity: gravity, width: width, height: height, radius: radius)
    element.apply_to(@canvas, &block)
  end

  def assert_placed_at(image, left:, top:)
    assert_equal [ left, top, 20, 20 ], image.find_trim(background: WHITE, threshold: 10)
  end
end
