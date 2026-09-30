# frozen_string_literal: true

require "test_helper"

class JekyllOgImage::Element::BorderTest < Minitest::Test
  WHITE = [ 255, 255, 255 ].freeze
  RED = [ 255, 0, 0 ].freeze
  GREEN = [ 0, 255, 0 ].freeze
  BLUE = [ 0, 0, 255 ].freeze
  COLORS = %w[#ff0000 #00ff00 #0000ff].freeze

  def setup
    @canvas = solid_image(300, 90, WHITE)
  end

  def test_bottom_border_with_single_color
    image = apply(10, position: :bottom, fill: "#ff0000")

    assert_equal RED, rgb_at(image, 0, 89)
    assert_equal RED, rgb_at(image, 299, 80)
    assert_equal WHITE, rgb_at(image, 150, 79)
  end

  def test_short_hex_fill
    image = apply(10, position: :bottom, fill: [ "#f00", "#00F" ])

    assert_equal RED, rgb_at(image, 0, 85)
    assert_equal BLUE, rgb_at(image, 299, 85)
  end

  def test_top_border
    image = apply(10, position: :top, fill: "#ff0000")

    assert_equal RED, rgb_at(image, 150, 0)
    assert_equal RED, rgb_at(image, 150, 9)
    assert_equal WHITE, rgb_at(image, 150, 10)
  end

  def test_left_border
    image = apply(10, position: :left, fill: "#ff0000")

    assert_equal RED, rgb_at(image, 9, 45)
    assert_equal WHITE, rgb_at(image, 10, 45)
  end

  def test_right_border
    image = apply(10, position: :right, fill: "#ff0000")

    assert_equal RED, rgb_at(image, 290, 45)
    assert_equal WHITE, rgb_at(image, 289, 45)
  end

  def test_horizontal_border_splits_colors_into_equal_stripes
    image = apply(10, position: :bottom, fill: COLORS)

    assert_equal [ RED, RED, GREEN, GREEN, BLUE, BLUE ],
      [ 0, 99, 100, 199, 200, 299 ].map { |x| rgb_at(image, x, 85) }
  end

  def test_vertical_border_splits_colors_into_equal_stripes
    image = apply(10, position: :left, fill: COLORS)

    assert_equal [ RED, RED, GREEN, GREEN, BLUE, BLUE ],
      [ 0, 29, 30, 59, 60, 89 ].map { |y| rgb_at(image, 5, y) }
  end

  def test_stripes_cover_full_length_when_not_evenly_divisible
    @canvas = solid_image(200, 90, WHITE)
    image = apply(10, position: :bottom, fill: COLORS)

    assert_equal BLUE, rgb_at(image, 199, 85)
  end

  def test_block_offsets_border_from_its_edge
    image = apply(10, position: :bottom, fill: "#ff0000") { { y: 5 } }

    assert_equal WHITE, rgb_at(image, 150, 89)
    assert_equal RED, rgb_at(image, 150, 84)
    assert_equal RED, rgb_at(image, 150, 75)
    assert_equal WHITE, rgb_at(image, 150, 74)
  end

  def test_rejects_invalid_position
    assert_raises(ArgumentError) { JekyllOgImage::Element::Border.new(10, position: :middle) }
  end

  private

  def apply(size, **opts, &block)
    JekyllOgImage::Element::Border.new(size, **opts).apply_to(@canvas, &block)
  end
end
