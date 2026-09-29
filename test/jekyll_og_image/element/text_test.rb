# frozen_string_literal: true

require "test_helper"

class JekyllOgImage::Element::TextTest < Minitest::Test
  WHITE = [ 255, 255, 255 ].freeze

  def setup
    @canvas = solid_image(200, 100, WHITE)
  end

  def test_nw_gravity_offsets_from_top_left
    left, top, = ink_box(render(gravity: :nw, x: 10, y: 20))

    assert_equal [ 10, 20 ], [ left, top ]
  end

  def test_ne_gravity_offsets_from_top_right
    left, top, width, = ink_box(render(gravity: :ne, x: 10, y: 20))

    assert_equal [ 10, 20 ], [ 200 - left - width, top ]
  end

  def test_sw_gravity_offsets_from_bottom_left
    left, top, _, height = ink_box(render(gravity: :sw, x: 10, y: 20))

    assert_equal [ 10, 20 ], [ left, 100 - top - height ]
  end

  def test_se_gravity_offsets_from_bottom_right
    left, top, width, height = ink_box(render(gravity: :se, x: 10, y: 20))

    assert_equal [ 10, 20 ], [ 200 - left - width, 100 - top - height ]
  end

  def test_defaults_to_top_left_without_block
    text = JekyllOgImage::Element::Text.new("Hi", dpi: 150, font: "Helvetica, Bold")
    left, top, = ink_box(text.apply_to(@canvas))

    assert_equal [ 0, 0 ], [ left, top ]
  end

  def test_renders_in_given_color
    image = render(gravity: :nw, x: 10, y: 20, color: "#ff0000")

    # Fully covered pixels are pure red; anti-aliased edges blend red with white
    red = (image[0] > 250) & (image[1] < 5) & (image[2] < 5)
    assert_equal 255, red.max
  end

  def test_renders_markup_characters_literally
    plain = JekyllOgImage::Element::Text.new("A and B", dpi: 150).apply_to(@canvas)
    ampersand = JekyllOgImage::Element::Text.new("A & B", dpi: 150).apply_to(@canvas)

    # "&" is drawn as a glyph, so the text is narrower than the three-letter "and"
    assert_operator ink_box(ampersand)[2], :<, ink_box(plain)[2]
  end

  def test_wraps_to_width
    one_line = ink_box(render(gravity: :nw, x: 0, y: 0, message: "Hello world"))
    wrapped = ink_box(render(gravity: :nw, x: 0, y: 0, message: "Hello world", width: 40))

    assert_operator wrapped[3], :>, one_line[3]
  end

  def test_rejects_invalid_gravity
    assert_raises(ArgumentError) { JekyllOgImage::Element::Text.new("Hi", gravity: :center) }
  end

  private

  def render(gravity:, x:, y:, message: "Hi", color: "#000000", width: nil)
    text = JekyllOgImage::Element::Text.new(message, gravity: gravity, color: color, width: width, dpi: 150, font: "Helvetica, Bold")
    text.apply_to(@canvas) { { x: x, y: y } }
  end

  # Returns [left, top, width, height] of everything that isn't background
  def ink_box(image)
    image.find_trim(background: WHITE, threshold: 10)
  end
end
